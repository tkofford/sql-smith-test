import csv
import sqlite3
# import sqlparse

import pytest as pytest
from sql_smith import QueryFactory
from sql_smith.engine import BasicEngine
from sql_smith.functions import field, alias, express
# from sqlparse.sql import IdentifierList, Identifier, Where, Parenthesis, Comparison
# from sqlparse.tokens import Keyword, DML

from db_client import DbClient

TEST_DATA_DIR = "data"
sql_tokens = []


@pytest.fixture(scope="module")
def db():
    # Fixture to set up the in-memory database with test data
    db_client = DbClient(sqlite3.connect(":memory:"))
    yield db_client
    db_client.close()


@pytest.fixture(scope="module")
def setup(db):
    # Create the brewery table
    ddl_file = open(f"{TEST_DATA_DIR}/brewery_table.sql", "r")
    create_table_query = ddl_file.read()
    db.execute(create_table_query)

    # Populate the brewery table
    data_file = open(f"{TEST_DATA_DIR}/brewery_data.csv", "r")
    reader = csv.reader(data_file)
    rows = []

    for row in reader:
        rows.append(row)

    db.executemany(
        "INSERT INTO brewery VALUES(?, ?, ?, ?, ?)", rows)
    db.commit()


@pytest.mark.usefixtures("setup")
def test_build_query(db):
    #  See https://fbraem.github.io/sql-smith/functions.html for sql-smith documentation
    include_type = True
    include_year = False
    limit = 10
    factory = QueryFactory(BasicEngine())
    query = factory \
        .select() \
        .from_("api_query")
    if include_type:
        query.and_where(field('type').in_("Brewpub", "Micro"))
    if include_year:
        query.and_where(field("YEAR_OPENED").between(1989, 2015))
    if limit:
        query.limit(limit)
    query = query.compile()


    print(query.sql)  # SELECT * FROM "breweries" WHERE "type" IN (?, ?) AND "YEAR_OPENED" BETWEEN ? AND ?
    print(query.params)  # ('Brewpub', 'Micro', 1989, 2015)
    qry: str = "with api_query as (select name, city, state, year_opened, type from brewery) " + query.sql
    print(qry)
    result = db.query_with_cols(qry, query.params)
    print(result)


@pytest.mark.usefixtures("setup")
def test_build_query2(db):
    #  See https://fbraem.github.io/sql-smith/functions.html for sql-smith documentation
    include_type = True
    include_year = True
    limit = 10
    factory = QueryFactory(BasicEngine())
    # cte_query = factory.select("name", "city", "state", "year_opened", "type").from_("brewery")
    cte_query = factory.select("name, city, state, year_opened, type FROM brewery")
    query = factory.select().from_("api_query")
    if include_type:
        query.and_where(field('type').in_("Brewpub", "Micro"))
    if include_year:
        cte_query.and_where(field("YEAR_OPENED").between(1989, 2015))
    if limit:
        query.limit(limit)
    cte_query = cte_query.compile()
    query = query.compile()

    print(query.sql)  # SELECT * FROM "breweries" WHERE "type" IN (?, ?) AND "YEAR_OPENED" BETWEEN ? AND ?
    print(query.params)  # ('Brewpub', 'Micro', 1989, 2015)
    qry: str = f"with api_query as ({cte_query.sql}) {query.sql}"
    print(qry)
    result = db.query_with_cols(qry, cte_query.params + query.params)
    print(result)


@pytest.mark.usefixtures("setup")
def test_build_query3(db):
    factory = QueryFactory(BasicEngine())
    query = factory \
        .select("name") \
        .from_("brewery") \
        .where(field("city").eq("Lawrence")) \
        .and_where(field("year_opened").eq(1989))

    query = query.compile()
    result = db.query_one_with_cols(query.sql, query.params)
    print(result)


@pytest.mark.usefixtures("setup")
def test_build_nested_query_in_from_clause(db):
    #  See https://fbraem.github.io/sql-smith/functions.html for sql-smith documentation
    factory = QueryFactory(BasicEngine())

    nested_query = factory.select().from_("brewery").where(field("city").eq("Lawrence"))
    outside_query = factory.select("brew.name").from_(alias(express("({})", nested_query), "brew"))
    query = outside_query.compile()
    print(query.sql)
    print(query.params)
    result = db.query_with_cols(query.sql, query.params)
    print(result)


@pytest.mark.usefixtures("setup")
def test_build_nested_query_in_where_clause(db):
    #  See https://fbraem.github.io/sql-smith/functions.html for sql-smith documentation
    factory = QueryFactory(BasicEngine())

    nested_query = factory.select("year_opened").distinct(True).from_("brewery").where(field("city").eq("Dodge City"))
    outside_query = factory.select("name, year_opened").from_("brewery").where(field("year_opened").in_(express("{}", nested_query)))
    query = outside_query.compile()
    print(query.sql)
    print(query.params)
    result = db.query_with_cols(query.sql, query.params)
    print(result)


# def test_sqlparse_query():
#     raw_query_file = open(f"{TEST_DATA_DIR}/flite.sql", "r")
#     sql = raw_query_file.read()
#
#     parsed = sqlparse.parse(sql)
#     stmt = parsed[0]
#     from_seen = False
#     select_seen = False
#     where_seen = False
#     groupby_seen = False
#     orderby_seen = False
#
#     for token in stmt.tokens:
#         if select_seen:
#             if isinstance(token, IdentifierList):
#                 for identifier in token.get_identifiers():
#                     print("{} {}\n".format("Attr = ", identifier))
#             elif isinstance(token, Identifier):
#                 print("{} {}\n".format("Attr = ", token))
#         if from_seen:
#             if isinstance(token, IdentifierList):
#                 for identifier in token.get_identifiers():
#                     print("{} {}\n".format("TAB = ", identifier))
#             elif isinstance(token, Identifier):
#                 print("{} {}\n".format("TAB = ", token))
#         if orderby_seen:
#             if isinstance(token, IdentifierList):
#                 for identifier in token.get_identifiers():
#                     print("{} {}\n".format("ORDERBY att = ", identifier))
#             elif isinstance(token, Identifier):
#                 print("{} {}\n".format("ORDERBY att = ", token))
#         if groupby_seen:
#             if isinstance(token, IdentifierList):
#                 for identifier in token.get_identifiers():
#                     print("{} {}\n".format("GROUPBY att = ", identifier))
#             elif isinstance(token, Identifier):
#                 print("{} {}\n".format("GROUPBY att = ", token))
#
#         if isinstance(token, Where):
#             select_seen = False
#             from_seen = False
#             where_seen = True
#             groupby_seen = False
#             orderby_seen = False
#             for where_tokens in token:
#                 if isinstance(where_tokens, Comparison):
#                     print("{} {}\n".format("Comparaison = ", where_tokens))
#                 elif isinstance(where_tokens, Parenthesis):
#                     print("{} {}\n".format("Parenthesis = ", where_tokens))
#                     # tables.append(token)
#         if token.ttype is Keyword and token.value.upper() == "GROUP BY":
#             select_seen = False
#             from_seen = False
#             where_seen = False
#             groupby_seen = True
#             orderby_seen = False
#         if token.ttype is Keyword and token.value.upper() == "ORDER BY":
#             select_seen = False
#             from_seen = False
#             where_seen = False
#             groupby_seen = False
#             orderby_seen = True
#         if token.ttype is Keyword and token.value.upper() == "FROM":
#             select_seen = False
#             from_seen = True
#             where_seen = False
#             groupby_seen = False
#             orderby_seen = False
#         if token.ttype is DML and token.value.upper() == "SELECT":
#             select_seen = True
#             from_seen = False
#             where_seen = False
#             groupby_seen = False
#             orderby_seen = False
