from __future__ import annotations

from typing import Any, Iterable


class DbClient(object):
    def __init__(self, connection):
        self._conn = connection
        self._cursor = self._conn.cursor()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    @property
    def connection(self):
        return self._conn

    @property
    def cursor(self):
        return self._cursor

    def commit(self):
        self.connection.commit()

    def close(self, commit=False):
        if commit:
            self.commit()
        self.connection.close()

    def execute(self, sql, params=None):
        try:
            self.cursor.execute(sql, params or ())
            print(self.cursor.rowcount, "row(s) affected.")
            # return self.cursor.fetchall()
        except Exception as ex:
            exception_message = f"Exception Occurred --> {ex}"
            raise Exception(exception_message)

    def executemany(self, sql: str, seq_of_param: Iterable[Iterable[Any]]):
        try:
            self.cursor.executemany(sql, seq_of_param)
            print(self.cursor.rowcount, "row(s) affected.")
            # return self.cursor.fetchall()
        except Exception as ex:
            exception_message = f"Exception Occurred --> {ex}"
            raise Exception(exception_message)

    def fetchall(self) -> list[tuple] | list[dict]:
        return self.cursor.fetchall()

    def fetchone(self) -> dict | tuple | None:
        return self.cursor.fetchone()

    def query(self, sql, params=None) -> list[tuple] | list[dict]:
        self.cursor.execute(sql, params or ())
        result = self.fetchall()
        return result

    def query_with_cols(self, sql, params=None) -> list[tuple] | list[dict]:
        self.cursor.execute(sql, params or ())
        columns = self.cursor.description
        result = [{columns[index][0]:column for index, column in enumerate(value)} for value in self.cursor.fetchall()]
        return result

    def query_one(self, sql, params=None) -> dict | tuple | None:
        self.cursor.execute(sql, params or ())
        return self.fetchone()

    def query_one_with_cols(self, sql, params=None) -> dict | tuple | None:
        self.cursor.execute(sql, params or ())
        columns = self.cursor.description
        row = self.cursor.fetchone()
        result = dict(zip([c[0] for c in columns], row))

        return result
