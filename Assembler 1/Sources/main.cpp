#include "Headers.h"

int main() {
	try {
		Controller* controller = new Controller(
			new Robot(),
			new Memory( 512 ),
			new Loader( "Map.txt" ),
			new Loader( "Program.txt" ),
			new Display(),
			new Keyboard()
		);
		controller->execute();

		cout << endl << "Program finished successfull" << endl;
	}
	catch ( const char* error ) {
		cout << endl << "Error: " << error << endl;
	}
	system( "pause" );
	return 0;
}