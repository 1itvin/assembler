#pragma once

#include "Headers.h"

class CommandPickUp : public Command {
public:
	bool execute( Controller* controller );
};