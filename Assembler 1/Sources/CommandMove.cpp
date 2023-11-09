#include "CommandMove.h"

bool CommandMove::execute( Controller* controller ) {
	Robot* robot = controller->robot;
	int x = (int)robot->x;
	int y = (int)robot->y;
	switch ( (int)robot->direction ) {
	case 0: // bottom
		y++;
		break;
	case 1: // left
		x--;
		break;
	case 2: // top
		y--;
		break;
	case 3: // lright
		x++;
		break;
	}
	if ( x >= 0 && x < 10 && y >= 0 && y < 10 ) {
		Memory* memory = controller->memory;
		if ( ( *memory )[ x + y * 10 ] != 1 ) {
			robot->x = x;
			robot->y = y;
		}
	}
	return true;
}