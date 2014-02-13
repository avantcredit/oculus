## 0.9.4 (Feb 13, 2014)

Adding auto clean of one time queries

* Any non named / non-author queries will be removed after configured time frame.
* Update of run to return to query page with new results

## 0.9.3 (June 19, 2012)

Breaking Changes:

* `Oculus.cache_path` removed, please use `Oculus.storage_options[:cache_path]`
  instead.

Features:

* Support for database-backed result storage (SequelStore). Usage:

        Oculus.storage_options = {
          adapter: 'sequel',
          uri:     'mysql://localhost/your_db',
          table:   'your_table'                 # default: oculus
        }

  *Jonathan Rudenberg*

* Hover actions for the SQL statement on the query detail page, to send it to
  the editor or rerun it.

* Command-R/Ctrl-R executes the query instead of reloading the page in most
  browsers.

Bugfixes:

* Escape special characters in query results.

  *Jonathan Rudenberg*

## 0.9.2 (June 2, 2012)

Initial public release
