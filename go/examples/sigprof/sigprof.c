#include "sigprof.h"

#include <stddef.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>

int sleep_30s() {
	time_t start = time(NULL);
	while (time(NULL) < start + 30) {
		char buffer[26];
		struct tm *tm_info;
		time_t timer;
		time(&timer);
		tm_info = localtime(&timer);
		strftime(buffer, 26, "%Y-%m-%d %H:%M:%S", tm_info);
		puts(buffer);

		sleep(1);
	}
}

int main() {
	go_listenAndServe();
	go_leakyFunc();
	sleep_30s();
	//go_start_cpuprofile();
	//go_stop_cpuprofile();
	return 0;
}


