/*Matrix.cpp*/
#include "Matrix.h"
#include <Windows.h>

/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/*CONSTRUCTORS*/
/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

/*Default Constructor*/
Matrix::Matrix()
{
}

/*Constructor*/
Matrix::Matrix(int sizeR, int sizeC, double* input_data)
{
	//OutputDebugString("Constructor Invoked\n");

	M = sizeR;									//reassign M and N values																										/*total rows*/
	N = sizeC;																																		/*total columns*/

	data = new double[M*N]; //point to a new double 1d array

	for (int ij = 0; ij < M*N; ij++)
	{
		data[ij] = input_data[ij]; //create matrix based on input_data pointer
	}
}

/*Copy Constructor*/
Matrix::Matrix(const Matrix& Mat)
{
	//OutputDebugString("Copy Constructor Invoked\n");

	M = Mat.M;		//reassign M and N
	N = Mat.N;


	data = new double[M*N]; //point to a new 1d array

	for (int ij = 0; ij < M*N; ij++)
	{
		data[ij] = Mat.data[ij]; //copy all elements of mat into the new array
	}
}

/*Destructor*/
Matrix::~Matrix()
{
	//OutputDebugString("Destructor Invoked\n");
	delete[] data;
}
/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/*OPERATOR OVERLOADS*/
/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

Matrix Matrix::operator+(const Matrix& other)
{
	//OutputDebugString("Operator '+' overload\n");
	Matrix temp;
	temp.M = other.M;
	temp.N = other.N;

	temp.data = new double[temp.M*temp.N];

	for (int x = 0; x < (temp.M*temp.N); x++)
	{
		temp.data[x] = this->data[x] + other.data[x]; //create a matrix based on calculation. 
	}

	return temp;
}

Matrix Matrix::operator=(const Matrix& other)
{
	//OutputDebugString("Operator '=' overload\n");
	delete[] data;

	M = other.M;
	N = other.N;

	data = new double[M*N];


	for (int x = 0; x < (M*N); x++)
	{
		this->data[x] = other.data[x];
	}

	return *this;
}

Matrix Matrix::operator*(const Matrix& other)
{
	//OutputDebugString("Operator '*' overload\n");
	Matrix temp;
	temp.M = other.M;
	temp.N = other.N;

	temp.data = new double[temp.M*temp.N];

	for (int x = 0; x < (temp.M*temp.N); x++)
	{
		temp.data[x] = this->data[x] * other.data[x];
	}

	return temp;
}

Matrix Matrix::operator-(const Matrix& other)
{
	//OutputDebugString("Operator '-' overload\n");

	Matrix temp;
	temp.M = other.M;
	temp.N = other.N;

	temp.data = new double[temp.M*temp.N];

	for (int x = 0; x < (temp.M*temp.N); x++)
	{
		temp.data[x] = this->data[x] - other.data[x];
	}

	return temp;
}

void Matrix::operator++(int)
{
	//OutputDebugString("Operator '++' overload\n");

	for (int x = 0; x < (this->M*this->N); x++)
	{
		this->data[x] = this->data[x] + 1;
	}
}

double Matrix::operator()(int i, int j)
{
	//OutputDebugString("Operator '()' overload\n");

	return this->get(i, j);
}

/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/*FUNCTIONS*/
/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

int Matrix::getM()
{
	return M;
}

int Matrix::getN()
{
	return N;
}

double* Matrix::getData()
{
	return data;
}


double Matrix::get(int i, int j)																						/*Retrieve data the 1D array based on (i, j) positions*/
{																														/*Formula = (k = i * _N + j), element = (row position * total columns of 2d array) + col position)*/
	return data[i*N + j];																								/*Return the element found in position (i,j) of the 1D array*/
}

void Matrix::set(int i, int j, double val)																				/*Function used to change a value of a specific element in the matrix*/
{																														/*Formula = (k = i * _N + j), element = (row position * total columns of 2d array) + col position)*/
	data[(i*N) + j] = val;																								/*Similar to the get function, except we don't return the value in position (i,j) of the 1D array, but rather change it*/
}

Matrix Matrix::getBlock(int start_row, int end_row, int start_col, int end_col)											/*Create a Matrix based on data in rows (i - j) and columns (i - j)*/
{
	int rows = (end_row - start_row) + 1;																				/*Total Rows/Columns = range of elements selected .*/
	int cols = (end_col - start_col) + 1;

	double* tempData = new double[rows*cols];

	int ctr = 0;

	for (int i = start_row; i < (rows + start_row); i++)
	{
		for (int j = start_col; j < (cols + start_col); j++)															 /*(cols + start_col)*/
		{
			tempData[ctr++] = get(i, j);
		}
	}

	Matrix temp(rows, cols, tempData);

	delete[] tempData;				//remove array from the heap

	return temp;
}

void Matrix::setBlock(int start_row, int end_row, int start_col, int end_col, Matrix& temp)
{
	int rows = (end_row - start_row) + 1;																				/*Total Rows/Columns = range of elements selected .*/
	int cols = (end_col - start_col) + 1;

	for (int i = start_row, ii = 0; i < (rows + start_row); i++, ii++)
	{
		for (int j = start_col, jj = 0; j < (cols + start_col); j++, jj++)
		{
			data[i*N + j] = temp.data[ii * cols + jj];
			//_data[i*_N + j] = 255;
		}
	}
}