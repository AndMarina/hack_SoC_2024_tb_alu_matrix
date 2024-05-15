xrun +access+rwc +xm64bit +timeout_us=10000 +max_err_count=10 -timescale 1ns/1ps -f $GIT_HOME/tb_files.lst \
-l log.log -linedebug -sv -seed random -gui \
+testname=TEST_BASIC
