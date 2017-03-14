#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include "Matrix.h"
#include "cv.h"

double* readTXT(char *fileName, int sizeR, int sizeC);

using namespace std;

int main()
{
	int M = 800; int N = 600;

	double* Fr_1 = new double[M*N];
	double* Fr_2 = new double[M*N];

	cout << endl;
	cout << "Data from text file -------------------------------------------" << endl;

	char* Fr1FileName = "E:\\Year 3/Project/ParallelCardiacImageProcessingProject/C++/Assignment_v13_cplusplusversion/Debug/Frame Data/Frame 1.txt";
	char* Fr2FileName = "E:\\Year 3/Project/ParallelCardiacImageProcessingProject/C++/Assignment_v13_cplusplusversion/Debug/Frame Data/Frame 2.txt";

	Fr_1 = readTXT(Fr1FileName, M, N);
	Fr_2 = readTXT(Fr2FileName, M, N);

	Matrix Fr1(M, N, Fr_1);
	Matrix Fr2(M, N, Fr_2);


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

void cvQuiver(int x, int y, int u, int v, cv::Scalar Color, int Size, int Thickness) {
	cv::Point pt1, pt2;
	double Theta;
	double PI = 3.1416;

	if (u == 0)
		Theta = PI / 2;
	else
		Theta = atan2(double(v), (double)(u));

	pt1.x = x;
	pt1.y = y;

	pt2.x = x + u;
	pt2.y = y + v;

	cv::line(Image, pt1, pt2, Color, Thickness, 8);  //Draw Line


	Size = (int)(Size*0.707);


	if (Theta == PI / 2 && pt1.y > pt2.y)
	{
		pt1.x = (int)(Size*cos(Theta) - Size*sin(Theta) + pt2.x);
		pt1.y = (int)(Size*sin(Theta) + Size*cos(Theta) + pt2.y);
		cv::line(Image, pt1, pt2, Color, Thickness, 8);  //Draw Line

		pt1.x = (int)(Size*cos(Theta) + Size*sin(Theta) + pt2.x);
		pt1.y = (int)(Size*sin(Theta) - Size*cos(Theta) + pt2.y);
		cv::line(Image, pt1, pt2, Color, Thickness, 8);  //Draw Line
	}
	else {
		pt1.x = (int)(-Size*cos(Theta) - Size*sin(Theta) + pt2.x);
		pt1.y = (int)(-Size*sin(Theta) + Size*cos(Theta) + pt2.y);
		cv::line(Image, pt1, pt2, Color, Thickness, 8);  //Draw Line

		pt1.x = (int)(-Size*cos(Theta) + Size*sin(Theta) + pt2.x);
		pt1.y = (int)(-Size*sin(Theta) - Size*cos(Theta) + pt2.y);
		cv::line(Image, pt1, pt2, Color, Thickness, 8);  //Draw Line
	}

}