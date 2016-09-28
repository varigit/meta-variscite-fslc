/*
 * Copyright (c) 2016 Variscite Ltd.
 *
 * This file is licensed under GNU GPL v2+
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/input.h>

int run_command_upon_event(const char *device, struct input_event *wanted_event, const char *command)
{
	int fd, select_ret, ret=-1;
	fd_set readfds;
	struct input_event event;
	ssize_t bytes_read;
	char dev_name[256] = "Unknown";

	fd = open(device, O_RDONLY);
	if (fd == -1) {
		perror("open()");
		return ret;
	}

	ioctl(fd, EVIOCGNAME(sizeof(dev_name)), dev_name);
	printf("Reading from %s (%s)\n", device, dev_name);

	FD_ZERO(&readfds);
	FD_SET(fd, &readfds);

	while (1) {
		select_ret = select(fd + 1, &readfds, NULL, NULL, NULL);
		if (select_ret == -1) {
			perror("select()");
			goto out;
		}

		if (FD_ISSET(fd, &readfds)) {
			bytes_read = read(fd, &event, sizeof(struct input_event));
			if (bytes_read == -1)
				perror("read()");
			if (bytes_read != sizeof(struct input_event))
				printf("read(): bytes read are not an input_event.\n");

			if (event.type == wanted_event->type &&
			    event.code == wanted_event->code &&
			    event.value == wanted_event->value)
				system(command);
		}
	}

out:
	if (close(fd) == -1)
		perror("close()");
	return ret;
}

int main(int argc, char *argv[])
{
	struct input_event event;

	if (argc != 4) {
		printf("Usage: %s input_device event_code command\n", argv[0]);
		printf("For example: %s /dev/input/event0 116 'shutdown -h -P now'\n\n", argv[0]);
		return 0;
	}

	/* Key release event */
	event.type = EV_KEY;
	event.value = 0;

	event.code = (int) strtol(argv[2], (char **)NULL, 10);

	return run_command_upon_event(argv[1], &event, argv[3]);
}
