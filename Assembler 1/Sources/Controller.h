#pragma once

#include "Headers.h"

class Controller {
private:
	Robot*		robot;
	Loader*		mapLoader;
	Loader*		programLoader;
	Display*	display;
	Keyboard*	keyboard;

	unsigned int	commandAddress;
	unsigned int	step;

public:
	Memory*			memory;

	Controller(
		Robot*		robot,
		Memory*		memory,
		Loader*		mapLoader,
		Loader*		programLoader,
		Display*	display,
		Keyboard*	keyboard
	);
	~Controller();

	void execute();

	friend class Display;

	friend class CommandMove;
	friend class CommandLeft;
	friend class CommandRight;
	friend class CommandPickUp;
	friend class CommandPut;

};