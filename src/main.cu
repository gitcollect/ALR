#include "gpu_pollard_p1_factorization.h"
#include "pollard_p1_factorization.h"
#include "rsacalculation.h"
#include <cuda.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "statistic_definitions.h"

void read_primes(unsigned long int *primes);

int main(int argc, char *argv[]) {
	unsigned long int primes_length = 78498;
	unsigned long int *primes = (unsigned long int *) malloc(sizeof(unsigned long int) * primes_length);
	int i, j;
	bool statisticMode = false;

	//time measurement
	clock_t start, end;

	long long int *p, *q, *n, e, d;
	n = (long long int*) malloc(sizeof(long long int));

	read_primes(primes);

	//*n = 65521LL * 65537LL;  //n6, biggest possible n
	//*n = 57037LL * 57041LL;  //n5
	//*n = 40709LL * 40739LL;  //n4
	//*n = 32621LL * 32633LL;  //n3!
	*n = 25087LL * 25097LL;  //n2
	//*n = 20903LL * 20921LL;  //n1
	//*n = 7331LL * 7333LL;
	//*n = 902491;
	e = 5;

	int choice;
	double cpuTime, gpuTime;
	bool isEnd = false;

	if (argc > 1) {
		if (strstr(argv[1], "-statistic") != NULL) {
			statisticMode = true;
			choice = 7;
			goto menu;
		}
	}

	while (!isEnd) {
		printf("------------- Menu ----------------\n");
		printf("1. CPU & GPU - starten mit Standard n und e ...\n");
		printf("2. CPU & GPU - Eingabe von n und e ...\n");
		printf("3. CPU - starten mit Standard n und e ...\n");
		printf("4. CPU - Eingabe von n und e ...\n");
		printf("5. GPU - starten mit Standard n ...\n");
		printf("6. GPU - Eingabe von n ...\n");
		printf("7. GPU - BlockSize/GridSize Statistik\n");
		printf("8. GPU - input n's out of file (statistic mode)\n");
		printf("99. Exit the program ...\n");
		printf("Eingabe choice: ");
		scanf("%d", &choice);

		menu: p = (long long int*) malloc(sizeof(long long int));
		q = (long long int*) malloc(sizeof(long long int));

		switch (choice) {
		case 1:
			printf("------------- Ausgabe -------------\n");
			printf("========= CPU ========\n");
			printf("CPU berchnung wird gestartet...\n");
			start = clock();
			pollard_p1_factorization(*n, p, q, primes, primes_length);
			end = clock();
			cpuTime = (end - start) / (double) CLOCKS_PER_SEC;
			printf("p = %lld\nq = %lld in %lu clocks\n", *p, *q, (unsigned long) (end - start));
			printf("Ergebnis nach (%lf) Sekunden : \np = %lld\nq = %lld \n", cpuTime, *p, *q);
			d = calculatePrivateKey(e, *p, *q);
			printf("d = %lld\n", d);

			printf("========= GPU ========\n");
			printf("GPU Register werden beschrieben\n");
			printf("GPU berechnung wird gestartet\n");
			start = clock();
			gpu_pollard_p1_factorization(*n, p, q, primes, primes_length);
			end = clock();
			gpuTime = (end - start) / (double) CLOCKS_PER_SEC;
			printf("p = %lld\nq = %lld in %lu clocks\n", *p, *q, (unsigned long) (end - start));
			printf("Ergebnis nach (%lf) Sekunden : \np = %lld\nq = %lld \n", gpuTime, *p, *q);

			printf("---------------------------\n");
			if (cpuTime > gpuTime) {
				printf("GPU war %lf Sekunden schneller\n", cpuTime - gpuTime);
				printf("GPU war %lf mal schneller\n", cpuTime / gpuTime);
			} else {
				printf("CPU war %lf Sekunden schneller\n", gpuTime - cpuTime);
				printf("CPU war %lf mal schneller\n", gpuTime / cpuTime);
			}
			break;
		case 2:
			printf("Eingabe n: ");
			scanf("%lld", n);
			printf("Eingabe e: ");
			scanf("%lld", &e);
			printf("You input n=%lld und e=%lld \n", *n, e);

			printf("------------- Ausgabe -------------\n");
			printf("========= CPU ========\n");
			printf("CPU berchnung wird gestartet...\n");
			start = clock();
			pollard_p1_factorization(*n, p, q, primes, primes_length);
			end = clock();
			cpuTime = (end - start) / (double) CLOCKS_PER_SEC;
			printf("p = %lld\nq = %lld in %lu clocks\n", *p, *q, (unsigned long) (end - start));
			printf("Ergebnis nach %lf Sekunden : \np = %lld\nq = %lld \n", cpuTime, *p, *q);
			d = calculatePrivateKey(e, *p, *q);
			printf("d = %lld\n", d);

			printf("========= GPU ========\n");
			printf("GPU Register werden beschrieben\n");
			printf("GPU berechnung wird gestartet\n");
			start = clock();
			gpu_pollard_p1_factorization(*n, p, q, primes, primes_length);
			end = clock();
			gpuTime = (end - start) / (double) CLOCKS_PER_SEC;
			printf("p = %lld\nq = %lld in %lu clocks\n", *p, *q, (unsigned long) (end - start));
			printf("Ergebnis nach (%lf) Sekunden : \np = %lld\nq = %lld \n", gpuTime, *p, *q);

			printf("---------------------------\n");
			if (cpuTime > gpuTime) {
				printf("GPU war %lf Sekunden schneller\n", cpuTime - gpuTime);
				printf("GPU war %lf mal schneller\n", cpuTime / gpuTime);
			} else {
				printf("CPU war %lf Sekunden schneller\n", gpuTime - cpuTime);
				printf("CPU war %lf mal schneller\n", gpuTime / cpuTime);
			}
			break;
		case 3:
			printf("------------- Ausgabe -------------\n");
			printf("========= CPU ========\n");
			printf("CPU berchnung wird gestartet...\n");
			start = clock();
			pollard_p1_factorization(*n, p, q, primes, primes_length);
			end = clock();
			cpuTime = (end - start) / (double) CLOCKS_PER_SEC;
			printf("p = %lld\nq = %lld in %lu clocks\n", *p, *q, (unsigned long) (end - start));
			printf("Ergebnis nach (%lf) Sekunden : \np = %lld\nq = %lld \n", cpuTime, *p, *q);
			d = calculatePrivateKey(e, *p, *q);
			printf("d = %lld\n", d);
			break;
		case 4:
			printf("Eingabe n: ");
			scanf("%lld", n);
			printf("Eingabe e: ");
			scanf("%lld", &e);
			printf("You input n=%lld und e=%lld \n", *n, e);

			printf("------------- Ausgabe -------------\n");
			printf("========= CPU ========\n");
			printf("CPU berchnung wird gestartet...\n");
			start = clock();
			pollard_p1_factorization(*n, p, q, primes, primes_length);
			end = clock();
			cpuTime = (end - start) / (double) CLOCKS_PER_SEC;
			printf("p = %lld\nq = %lld in %lu clocks\n", *p, *q, (unsigned long) (end - start));
			printf("Ergebnis nach %lf Sekunden : \np = %lld\nq = %lld \n", cpuTime, *p, *q);
			d = calculatePrivateKey(e, *p, *q);
			printf("d = %lld\n", d);
			break;
		case 5:
			printf("------------- Ausgabe -------------\n");
			printf("========= GPU ========\n");
			printf("GPU Register werden beschrieben\n");
			printf("GPU berechnung wird gestartet\n");
			start = clock();
			gpu_pollard_p1_factorization(*n, p, q, primes, primes_length);
			end = clock();
			gpuTime = (end - start) / (double) CLOCKS_PER_SEC;
			printf("p = %lld\nq = %lld in %lu clocks\n", *p, *q, (unsigned long) (end - start));
			printf("Ergebnis nach (%lf) Sekunden : \np = %lld\nq = %lld \n", gpuTime, *p, *q);
			break;
		case 6:
			printf("Eingabe n: ");
			scanf("%lld", n);
			printf("You input n=%lld\n", *n);

			printf("------------- Ausgabe -------------\n");
			printf("========= GPU ========\n");
			printf("GPU Register werden beschrieben\n");
			printf("GPU berechnung wird gestartet\n");
			start = clock();
			gpu_pollard_p1_factorization(*n, p, q, primes, primes_length);
			end = clock();
			gpuTime = (end - start) / (double) CLOCKS_PER_SEC;
			printf("p = %lld\nq = %lld in %lu clocks\n", *p, *q, (unsigned long) (end - start));
			printf("Ergebnis nach (%lf) Sekunden : \np = %lld\nq = %lld \n", gpuTime, *p, *q);
			break;
		case 7: //first run takes longer, remove from statistics
			gpu_pollard_p1_factorization(*n, p, q, primes, primes_length);

			printf("gridSize;blockSize;p;q;clocks;seconds\n");
			for (i = 1; i <= STATISTIC_MAX_GRIDSIZE; i *= STATISTIC_GRIDSIZE_MULTIPLIER) {
				setGridSize(i);
				for (j = STATISTIC_BLOCKSIZE_STEPSIZE; j <= STATISTIC_MAX_BLOCKSIZE; j += STATISTIC_BLOCKSIZE_STEPSIZE) {
					if (i * j > STATISTIC_MAX_THREADS) {
						continue;
					}
					setBlockSize(j);
					start = clock();
					gpu_pollard_p1_factorization(*n, p, q, primes, primes_length);
					end = clock();
					gpuTime = (end - start) / (double) CLOCKS_PER_SEC;
					printf("%d;%d;%lld;%lld;%lu;%lf\n", getGridSize(), getBlockSize(), *p, *q, (unsigned long) (end - start), gpuTime);
					*p = 1;
					*q = 1;
				}
			}
			if (statisticMode) {
				isEnd = true;
			}
			break;
		case 8:{
			FILE *input, *output, *statOutput;
			char filename[50];
			char buff[25];
			input = fopen("src/fileofN.txt", "r");
			output = fopen("statistic/outputCalculation.txt", "a+");

			//open and create statistic output file for excel import
			time_t timeforFilename = time(0);
			strftime(buff, 25, "%Y%m%d_%H_%M_%S", localtime(&timeforFilename));
			sprintf(filename,"statistic/statOutput_%s.csv", buff);
			statOutput = fopen(filename, "w");

			fprintf(output,"_____________________________________________________________________________________________________________________________________________________________________________\n");
			fprintf(output," 	n		|	 	TimeStamp		 |		  CPU(p,q)		   |		CPU time		|		  GPU(p,q)		   |		  GPU time		|						Result		\n");

			// read n's out of file and calculate
			while ((fscanf(input, "%lld,", n)) != EOF) {
				// log n to output
				fprintf(output, "%lld		", *n);
				// log n to statOutput
				fprintf(statOutput, "%lld;", *n);
				//timestamp output
				time_t nowtime = time(0);
				strftime(buff, 25, "%Y-%m-%d %H:%M:%S", localtime(&nowtime));
				fprintf(output, "%s		", buff);
				// CPU calculation
				start = clock();
				pollard_p1_factorization(*n, p, q, primes, primes_length);
				end = clock();
				// log result of p and q
				fprintf(output, "(C) p=%lld, q=%lld		", *p, *q);
				cpuTime = (end - start) / (double) CLOCKS_PER_SEC;
				// log result of CPU and time
				fprintf(output, "%lf Sekunden		", cpuTime);
				// log CPU time to statOutput
				fprintf(statOutput, "%lf;", cpuTime);
				// GPU calculation
				start = clock();
				gpu_pollard_p1_factorization(*n, p, q, primes, primes_length);
				end = clock();
				// log result of p and q
				fprintf(output, "(G) p=%lld, q=%lld		", *p, *q);
				gpuTime = (end - start) / (double) CLOCKS_PER_SEC;
				// log result of GPU and time
				fprintf(output, "%lf Sekunden		", gpuTime);
				// log CPU time to statOutput
				fprintf(statOutput, "%lf;", gpuTime);
				// log result of CPU and GPU, calculate which is faster
				if (cpuTime > gpuTime) {
					fprintf(output, "GPU %lf Sekunden | %lf mal schneller\n", cpuTime - gpuTime, cpuTime / gpuTime);
				} else {
					fprintf(output, "CPU %lf Sekunden | %lf mal schneller\n", gpuTime - cpuTime, gpuTime / cpuTime);
				}
				fprintf(statOutput, "%lld;%lld;\n", *p, *q);
				fprintf(output, "\n");
			}

			fclose(input);
			fclose(output);
			fclose(statOutput);
			}
			break;
		default:
			isEnd = true;
			break;
		}
		free(p);
		free(q);
	}

	return 0;
}

void read_primes(unsigned long int *primes) {
	FILE *datei;
	unsigned long int prime;
	int count = 0;

	datei = fopen("src/primes.txt", "r");
	while ((fscanf(datei, "%lu,", &prime)) != EOF) {
		primes[count++] = prime;
	}
	fclose(datei);
}
