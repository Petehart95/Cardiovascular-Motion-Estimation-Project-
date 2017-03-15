#pragma once
#include <iostream>
#include "Matrix.h"

class TSS : public Matrix
{
	
private:


public:
	static void TSS::Search(Matrix& Fr1, Matrix& Fr2, int M, int N);
	static int TSS::SAD(Matrix& Block1, Matrix& Block2, int M, int N);

};