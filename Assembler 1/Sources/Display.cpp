#include "Display.h"

void Display::print( Controller* controller ) {
	Robot* robot = controller->robot;
	cout << "Markers: " << (int)robot->markers << endl;
	cout << "Step: " << (int)controller->step << endl;
	cout << endl;

	for ( int y = 0; y < 10; y++ ) {
		for ( int x = 0; x < 10; x++ ) {
			int code = 0;
			if ( x == robot->x && y == robot->y ) {
				switch ( (int)robot->direction ) {
				case 0: // bottom
					code = 209;
					break;
				case 1: // left
					code = 182;
					break;
				case 2: // top
					code = 207;
					break;
				case 3: // right
					code = 199;
					break;
				}
			} else {
				Memory* memory = controller->memory;
				switch ( ( *memory )[ x + y * 10 ] ) {
				case 0: // empty 
					code = 32;
					break;
				case 1: // barrier
					code = 254;
					break;
				case 2: // marker
					code = 109;
					break;
				}
			}
			cout << setw( 2 ) << (char)code;
		}
		cout << endl;
	}
}