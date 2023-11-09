#include "CommandRight.h"

bool CommandRight::execute( Controller* controller ) {
	Robot* robot = controller->robot;
	int direction = (int)robot->direction + 1;
	if ( direction > 3 ) {
		robot->direction = 0;
	} else {
		robot->direction = direction;
	}
	return true;
}