Dear MySQL users,

MySQL Server 5.7.15, a new version of the popular Open Source
Database Management System, has been released. MySQL 5.7.15 is
recommended for use on production systems.

For an overview of what's new in MySQL 5.7, please see

http://dev.mysql.com/doc/refman/5.7/en/mysql-nutshell.html

For information on installing MySQL 5.7.15 on new servers, please see
the MySQL installation documentation at

http://dev.mysql.com/doc/refman/5.7/en/installing.html

MySQL Server 5.7.15 is available in source and binary form for a number of
platforms from our download pages at

http://dev.mysql.com/downloads/mysql/

MySQL Server 5.7.15 is also available from our repository for Linux
platforms, go here for details:

http://dev.mysql.com/downloads/repo/

Windows packages are available via the Installer for Windows or .ZIP
(no-install) packages for more advanced needs. The point and click
configuration wizards and all MySQL products are available in the
unified Installer for Windows:

http://dev.mysql.com/downloads/installer/

5.7.15 also comes with a web installer as an alternative to the full
installer.

The web installer doesn't come bundled with any actual products
and instead relies on download-on-demand to fetch only the
products you choose to install. This makes the initial download
much smaller but increases install time as the individual products
will need to be downloaded.

We welcome and appreciate your feedback, bug reports, bug fixes,
patches, etc.:

http://bugs.mysql.com/report.php

The following section lists the changes in MySQL 5.7 since
the release of MySQL 5.7.14. It may also be viewed online at

http://dev.mysql.com/doc/relnotes/mysql/5.7/en/news-5-7-15.html

Enjoy!

Changes in MySQL 5.7.15 (2016-09-06)

   Security Notes

     * The validate_password plugin now supports the capability
       of rejecting passwords that match the current session
       user name, either forward or in reverse. To enable
       control over this capability, the plugin exposes a
       validate_password_check_user_name system variable. By
       default, this variable is disabled; the default will
       change to enabled in MySQL 8.0. For more information, see
       Password Validation Plugin Options and Variables

(http://dev.mysql.com/doc/refman/5.7/en/validate-password-options-variables.html).

   Test Suite Notes

     * In mysql-test-run.pl, a limit of 50 was imposed on the
       number of workers for parallel testing, which on systems
       with more than 50 CPUs resulted in exhaustion of unique
       thread IDs. The ID-exhaustion problem has been corrected,
       and the limit of 50 on number of workers has been lifted.
       Thanks to Daniel Black for the patch on which this change
       was based. Additionally, these changes were made:

          + To avoid idle workers, the number of parallel
            workers now is limited to the number of tests.

          + Previously, if --parallel=auto was given and the
            MTR_MAX_PARALLEL environment variable was not set, a
            limit of 8 was imposed on the number of parallel
            workers. This limit has been lifted.
       (Bug #22342399, Bug #79585)

   Functionality Added or Changed

     * InnoDB: A new dynamic configuration option,
       innodb_deadlock_detect, can be used to disable deadlock
       detection. On high concurrency systems, deadlock
       detection can cause a slowdown when numerous threads wait
       for the same lock. At times, it may be more efficient to
       disable deadlock detection and rely on the
       innodb_lock_wait_timeout setting for transaction rollback
       when a deadlock occurs. (Bug #23477773)

   Bugs Fixed

     * InnoDB: An ALTER TABLE ... ENCRYPTION='Y', ALGORITHM=COPY
       operation on a table residing in the system tablespace
       raised an assertion. (Bug #24381804)

     * InnoDB: Creating an encrypted table on a Fusion-io disk
       with an innodb_flush_method setting of O_DIRECT caused a
       fatal error. (Bug #24329079, Bug #82073)

     * InnoDB: An operation that dropped and created a full-text
       search table raised an assertion. (Bug #24315031)

     * InnoDB: Accessing full-text search auxiliary tables while
       dropping the indexed table raised an assertion. (Bug
       #24009272)

     * InnoDB: An online DDL operation on a table with indexed
       BLOB columns raised an assertion during logging of table
       modifications. (Bug #23760086)

     * InnoDB: In some cases, code that locates a buffer pool
       chunk corresponding to given pointer returned the wrong
       chunk.
       Thanks to Alexey Kopytov for the patch. (Bug #23631471,
       Bug #79378)

     * mysqld_safe attempted to read my.cnf in the data
       directory, although that is no longer a standard option
       file location. (Bug #24482156)

     * For mysqld_safe, the argument to --malloc-lib now must be
       one of the directories /usr/lib, /usr/lib64,
       /usr/lib/i386-linux-gnu, or /usr/lib/x86_64-linux-gnu. In
       addition, the --mysqld and --mysqld-version options can
       be used only on the command line and not in an option
       file. (Bug #24464380)

     * It was possible to write log files ending with .ini or
       .cnf that later could be parsed as option files. The
       general query log and slow query log can no longer be
       written to a file ending with .ini or .cnf. (Bug
       #24388753)

     * Privilege escalation was possible by exploiting the way
       REPAIR TABLE used temporary files. (Bug #24388746)

     * The client library failed to build on Solaris using the
       Cstd library. (Bug #24353920)

     * If the basedir system variable was set at server startup
       from the command line or option file, the value was not
       normalized (on Windows, / was not replaced with /). (Bug
       #23747899, Bug #82125)

     * kevent statement timer subsystem deinitialization was
       revised to avoid a mysqld hang during shutdown on OS X
       10.12. (Bug #23744004, Bug #82097)

     * For accounts for which multiple GRANT statements applied,
       mysqlpump could fail to dump them all. (Bug #23721446)

     * The MYSQL_ADD_PLUGIN macro had a spelling error that
       caused MYSQL_SERVER not to be defined. (Bug #23508762,
       Bug #81666)

     * In-place ALTER TABLE operations which when executed
       separately caused no table rebuild could when combined
       into a single statement result in a table rebuild. (Bug
       #23475211, Bug #81587)

     * For keyring plugins, the data access layer is now created
       only as necessary, not once per operation, which improves
       keyring performance. (Bug #23337926)

     * A blank server name in CREATE SERVER statements produced
       a server exit rather than an error. (Bug #23295288)

     * The optimizer failed to check a function return value for
       an area calculation, leading to a server exit. (Bug
       #23280059)

     * The server could fail to free memory allocated for
       execution of queries that used generated columns. (Bug
       #23205454)
       References: This issue is a regression of: Bug #22392268.

     * mysqlpump output for triggers that contained multiple
       statements in the trigger body failed to load correctly.
       (Bug #23072245)

     * Queries that satisfied the following conditions could
       return different results than in MySQL 5.6: 1) A subquery
       appeared in the select list; 2) The subquery contained a
       WHERE condition that referenced a value in the outer
       query; 3) The outer query contained a GROUP BY that
       required creation of a temporary table. (Bug #23049975)

     * Passwords that were rejected by the validate_password
       plugin were written by the server to the error log as
       cleartext. (Bug #22922023)

     * A prepared statement that used a parameter in the select
       list of a derived table that was part of a join could
       cause a server exit. (Bug #22392374, Bug #24380263)

     * MEDIUMINT columns used in operations with long integer
       values could result in buffer overflow. (Bug #19984392)

     * A spurious ER_NO_SUCH_TABLE error could occur when
       attempting to execute a prepared CREATE TABLE ... SELECT
       statement that used a temporary table in the FROM clause
       and called a stored function. The same error could occur
       for a nonprepared version of the statement if used in a
       stored procedure when the procedure was re-executed. (Bug
       #16672723, Bug #68972)

     * EINTR handling in the client library has been fixed so
       that interrupted read and write calls are retried.
       Previously, EINTR was ignored. (Bug #82019, Bug
       #23703570) 

On Behalf of the MySQL/ORACLE RE Team
Hery Ramilison
