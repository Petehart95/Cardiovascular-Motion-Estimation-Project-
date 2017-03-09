#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main() {
	ifstream file("Frame 1.txt");
	string str;
	string file_contents [800] [600];

	for (int i = 0; i <= 800; i++)
	{
		for (int j = 0; j <= 600; j++)
		{
			getline(file, str);
			file_contents[i][j] = str;
		}
	}
	return 0;
}