#include "CommandLeft.h"

bool CommandLeft::execute( Controller* controller ) {
	Robot* robot = controller->robot;
	int direction = (int)robot->direction - 1;
	if ( direction < 0 ) {
		robot->direction = 3;
	} else {
		robot->direction = direction;
	}
	return true;
}