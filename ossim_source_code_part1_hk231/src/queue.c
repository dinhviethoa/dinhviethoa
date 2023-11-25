#include <stdio.h>
#include <stdlib.h>
#include "queue.h"

int empty(struct queue_t * q) {
	return (q->size == 0);
}

void enqueue(struct queue_t * q, struct pcb_t * proc) {
	/* TODO: put a new process to queue [q] */
	if (q->size == MAX_QUEUE_SIZE) {
		printf("Queue is full\n");
		return;
	}
	q->proc[q->size] = proc;
	q->size++;
}

struct pcb_t * dequeue(struct queue_t * q) {
	/* TODO: return a pcb whose prioprity is the highest
	 * in the queue [q] and remember to remove it from q
	 * */
	if (q->size == 0) {
		printf("Queue is empty\n");
		return NULL;
	}
	int h_index = 0; // Index of the highest priority process
	int i;
	for (i = 1; i < q->size; i++) {
		if (q->proc[i]->priority < q->proc[h_index]->priority) {
			h_index = i;
		}
	}
	struct pcb_t * proc = q->proc[h_index];
	for (i = h_index; i < q->size - 1; i++) {
		q->proc[i] = q->proc[i + 1];
	}
	q->size--;
	return proc;
}