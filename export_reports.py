import pandas as pd
import sqlalchemy

engine = sqlalchemy.create_engine('postgresql://arbitr:arbitr@localhost:5432/arbitr')


def load_report(query: str, conn: sqlalchemy.Connection) -> pd.DataFrame:
    sql = sqlalchemy.sql.text(query)
    return pd.read_sql(sql, conn)


if __name__ == '__main__':
    with engine.connect() as conn, pd.ExcelWriter('reports.xlsx', engine='xlsxwriter') as writer:
        load_report('select * from report_register_debt', conn).to_excel(writer, sheet_name='report_register_debt',
                                                                         index=False)

        load_report('select * from report_current_debt', conn).to_excel(writer, sheet_name='report_current_debt',
                                                                        index=False)

        load_report('select * from report_cost', conn).to_excel(writer, sheet_name='report_cost', index=False)

        load_report('select * from report_voices', conn).to_excel(writer, sheet_name='report_voices', index=False)
