
Bug

1. truncate segement fault, when try to truncate 1G memory hole. consider another way to handle hole, or add cache size check when do trucate. 

E0617 23:43:13.411146  6654 Logging.cpp:64]     @     0x7fabc8bb2773 std::terminate()          [12/1823]
E0617 23:43:13.413592  6654 Logging.cpp:64]     @     0x7fabc8bb2993 __cxa_throw
E0617 23:43:13.416141  6654 Logging.cpp:64]     @     0x7fabc8bb2f2d operator new()
E0617 23:43:13.420310  6654 Logging.cpp:64]     @           0x5b2cb6 __gnu_cxx::new_allocator<>::allocat
e()
E0617 23:43:13.424250  6654 Logging.cpp:64]     @           0x5b2c13 std::_Vector_base<>::_M_allocate()
E0617 23:43:13.428809  6654 Logging.cpp:64]     @           0x5b2b2b std::_Vector_base<>::_M_create_stor
age()
E0617 23:43:13.431052  6654 Logging.cpp:64]     @           0x5b2907 std::_Vector_base<>::_Vector_base()
E0617 23:43:13.434661  6654 Logging.cpp:64]     @           0x5b24de std::vector<>::vector()
E0617 23:43:13.436722  6654 Logging.cpp:64]     @           0x632899 QS::Data::File::Truncate()

2. Cache memory issue (Free)

exmaple1: cp when surpass cache size

exmaple2: iozone test 128M 
Log line format: [IWEF]mmdd hh:mm:ss.uuuuuu threadid file:line] msg
E0622 09:01:48.756489 45359 Logging.cpp:64] *** Aborted at 1529629308 (unix time) try "date -d @1529629308" if you are using GNU date ***
E0622 09:01:48.757508 45359 Logging.cpp:64] PC: @                0x0 (unknown)
E0622 09:01:48.757611 45359 Logging.cpp:64] *** SIGSEGV (@0x31) received by PID 44128 (TID 0x7fbbb67fc700) from PID 49; stack trace: ***
E0622 09:01:48.784231 45359 Logging.cpp:64]     @     0x7fbc2dccd100 (unknown) <??:0>
E0622 09:01:48.804145 45359 Logging.cpp:64]     @     0x7fbc2d168077 std::__detail::_List_node_base::_M_unhook() <??:0>
E0622 09:01:48.826907 45359 Logging.cpp:64]     @           0x600989 std::list<>::_M_erase() <stl_list.h:1571>
E0622 09:01:48.847844 45359 Logging.cpp:64]     @           0x6002dd std::list<>::erase() <list.tcc:113>
E0622 09:01:48.870051 45359 Logging.cpp:64]     @           0x5fda3d QS::Data::Cache::Free() <Cache.cpp:154 (discriminator 1)>
E0622 09:01:48.896625 45359 Logging.cpp:64]     @           0x61d031 QS::Data::File::PreWrite() <File.cpp:428 (discriminator 2)>
E0622 09:01:48.922823 45359 Logging.cpp:64]     @           0x61c8ba QS::Data::File::Write() <File.cpp:388>
E0622 09:01:48.958232 45359 Logging.cpp:64]     @           0x64517a QS::FileSystem::Drive::WriteFile() <Drive.cpp:798>
E0622 09:01:48.982509 45359 Logging.cpp:64]     @           0x66d871 QS::FileSystem::qsfs_write() <Operations.cpp:1134 (discriminator 1)>
E0622 09:01:49.002197 45359 Logging.cpp:64]     @     0x7fbc2dee7adc fuse_fs_write_buf <??:0>
E0622 09:01:49.016885 45359 Logging.cpp:64]     @     0x7fbc2dee7c58 (unknown) <??:0>
E0622 09:01:49.031461 45359 Logging.cpp:64]     @     0x7fbc2def0d68 (unknown) <??:0>
E0622 09:01:49.045989 45359 Logging.cpp:64]     @     0x7fbc2deed471 (unknown) <??:0>
E0622 09:01:49.064828 45359 Logging.cpp:64]     @     0x7fbc2dcc5dc5 start_thread <??:0>
E0622 09:01:49.089201 45359 Logging.cpp:64]     @     0x7fbc2c915ced __clone <??:0>
E0622 09:01:49.108701 45359 Logging.cpp:64]     @                0x0 (unknown) <??:0>