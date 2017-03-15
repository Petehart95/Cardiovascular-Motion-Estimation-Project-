#pragma once
/*Matrix.h*/
#include <iostream>

class Matrix
{
	/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
	/* VARIABLES */
	/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

protected:
	int M;																															/*Total Rows*/
	int N;																															/*Total Columns*/
	double* data;																													/*Pointer to point at 1D data*/

																																	/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
																																	/* CONSTRUCTOR/DESTRUCTOR OVERLOADS */
																																	/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

public:
	Matrix::Matrix();																												/*Default Constructor*/
	Matrix::Matrix(int, int, double*);																								/*Constructor*/
	Matrix::Matrix(const Matrix&);																									/*Copy Constructor*/
	~Matrix();																														/*Destructor*/

																																	/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
																																	/* OPERATOR OVERLOADS */
																																	/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

	Matrix Matrix::operator+(const Matrix&);																						/*Addition Operator*/
	Matrix Matrix::operator=(const Matrix&);																						/*Assignment Operator*/
	Matrix Matrix::operator*(const Matrix&);																						/*Multiplication Operator*/
	Matrix Matrix::operator-(const Matrix&);																						/*Subtraction Operator*/
	void Matrix::operator++(int);																									/*Increment Operator*/
	double Matrix::operator()(int, int);																							/*Subscript Operator*/

																																	/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
																																	/* FUNCTIONS */
																																	/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

	Matrix Matrix::getBlock(int, int, int, int);																					/*Retrieve the values of the elements between points (i, j) and (ii, jj)*/
	int Matrix::getN();																												/*Retrieve value of N (total rows)*/
	int Matrix::getM();																												/*Retrieve value of M (total columns)*/
	double* Matrix::getData();																										/*Retrieve data (as a pointer)*/
	double Matrix::get(int, int);																									/*Retrieve element in position (i,j)*/
	void Matrix::set(int, int, double);																								/*Set the value of the element in position (i,j) as value (double)*/
	void Matrix::setBlock(int, int, int, int, Matrix&);																				/*Set the values of the elements between points (i, j) and (ii, jj) with the values of (Matrix)*/
};

