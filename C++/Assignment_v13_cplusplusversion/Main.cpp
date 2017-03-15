#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include "Matrix.h"
#include "ThreeStepSearch.h"

double* readTXT(char *fileName, int sizeR, int sizeC);

using namespace std;

int main()
{
	int M = 800; int N = 600;

	double* Fr_1 = new double[M*N];
	double* Fr_2 = new double[M*N];

	cout << endl;
	cout << "Data from text file -------------------------------------------" << endl;

	char* Fr1FileName = "E:\\Year 3/Project/ParallelCardiacImageProcessingProject/Matlab/dicomConversion/Frame Data/Frame 1.txt";
	char* Fr2FileName = "E:\\Year 3/Project/ParallelCardiacImageProcessingProject/Matlab/dicomConversion/Frame Data/Frame 2.txt";

	Fr_1 = readTXT(Fr1FileName, M, N);
	Fr_2 = readTXT(Fr2FileName, M, N);

	Matrix Fr1(M, N, Fr_1);
	Matrix Fr2(M, N, Fr_2);

	TSS::Search(Fr1, Fr2, M, N);

	getchar();


	return 0;
}

double* readTXT(char *fileName, int sizeR, int sizeC)
{
	double* data = new double[sizeR*sizeC];
	int i = 0;
	ifstream myfile(fileName);
	if (myfile.is_open())
	{

		while (myfile.good())
		{
			if (i>sizeR*sizeC - 1) break;
			myfile >> *(data + i);
			i++;
		}
		myfile.close();
	}

	else cout << "Unable to open file";

	return data;
}
