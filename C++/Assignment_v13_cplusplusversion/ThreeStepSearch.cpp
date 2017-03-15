#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include "Matrix.h"
#include "ThreeStepSearch.h"
#include <cmath>        // std::abs



void TSS::Search(Matrix& Fr1, Matrix& Fr2, int M, int N)
{
	int B = 20; //block size
	int S = 4; //step size
	int x2;
	int y2; 
	int blockM; //blockM/N for storing the block sizes per step
	int blockN;
	int SAD;
	int bestSAD;
	int xtemp;
	int ytemp;

	Matrix kOrg, k0, k1, k2, k3, k4, k5, k6, k7, k8;

	for (int x1 = 110; x1 < M; x1 += B)
	{
		for (int y1 = 110; y1 < N; y1 += B)
		{
			S = 4;
			x2 = x1;
			y2 = y1;
			do
			{
				blockM = S + 1;
				blockN = S + 1;

				kOrg = Fr1.getBlock(x1, x1 + S, y1, y1 + S);
				k0 = Fr2.getBlock(x2, x2 + S, y2, y2 + S);

				k1 = Fr2.getBlock(x2 - S, x2, y2 - S, y2);
				k2 = Fr2.getBlock(x2, x2 + S, y2 - S, y2);
				k3 = Fr2.getBlock(x2 + S, x2 + (S * 2), y2 - S, y2);
				k4 = Fr2.getBlock(x2 - S, x2, y2, y2 + S);
				k5 = Fr2.getBlock(x2 + S, x2 + (S * 2), y2, y2 + S);
				k6 = Fr2.getBlock(x2 - S, x2, y2 + S, y2 + (S * 2));
				k7 = Fr2.getBlock(x2, x2 + S, y2 + S, y2 + (S * 2));
				k8 = Fr2.getBlock(x2 + S, x2 + (S * 2), y2 + S, y2 + (S * 2));

				bestSAD = TSS::SAD(kOrg, k0, blockM, blockN);
				xtemp = x2;
				ytemp = y2;

				//K1 Check
				SAD = TSS::SAD(kOrg, k1, blockM, blockN);
				if (SAD < bestSAD)
				{
					bestSAD = SAD;
					xtemp = x2 - S;
					ytemp = y2 - S;
				}

				//K2 Check
				SAD = TSS::SAD(kOrg, k2, blockM, blockN);
				if (SAD < bestSAD)
				{
					bestSAD = SAD;
					ytemp = y2;
					xtemp = x2 - S;
				}

				//K3 Check
				SAD = TSS::SAD(kOrg, k3, blockM, blockN);
				if (SAD < bestSAD)
				{
					bestSAD = SAD;
					ytemp = y2 + S;
					xtemp = x2 - S;
				}

				//K4 Check
				SAD = TSS::SAD(kOrg, k4, blockM, blockN);
				if (SAD < bestSAD)
				{
					bestSAD = SAD;
					ytemp = y2 - S;
					xtemp = x2;
				}

				//K5 Check
				SAD = TSS::SAD(kOrg, k5, blockM, blockN);
				if (SAD < bestSAD)
				{
					bestSAD = SAD;
					ytemp = y2 + S;
					xtemp = x2;
				}

				//K6 Check
				SAD = TSS::SAD(kOrg, k6, blockM, blockN);
				if (SAD < bestSAD)
				{
					bestSAD = SAD;
					ytemp = y2 - S;
					xtemp = x2 + S;
				}

				//K7 Check
				SAD = TSS::SAD(kOrg, k7, blockM, blockN);
				if (SAD < bestSAD)
				{
					bestSAD = SAD;
					ytemp = y2;
					xtemp = x2 + S;
				}

				//K8 Check
				SAD = TSS::SAD(kOrg, k8, blockM, blockN);
				if (SAD < bestSAD)
				{
					bestSAD = SAD;
					ytemp = y2 + S;
					xtemp = x2 + S;
				}

				y2 = ytemp;
				x2 = xtemp;
				S = S / 2;
			} while (S > 1);
		}
	} //for loop ends here

}

int TSS::SAD(Matrix& Block1, Matrix& Block2, int M, int N)
{
	int block1SUM = 0;
	int block2SUM = 0;
	int SAD = 0;

	for (int i = 0; i <= M; i++)
	{
		for (int j = 0; j <= N; j++)
		{
			block1SUM += Block1.get(i, j);
			block2SUM += Block2.get(i, j);
		}
	}
	SAD = std::abs(block1SUM - block2SUM);
	return SAD;
}

