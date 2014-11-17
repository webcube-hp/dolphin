// Copyright 2013 Dolphin Emulator Project
// Licensed under GPLv2
// Refer to the license.txt file included.

#pragma once

#include "InputCommon/ControllerInterface/Device.h"
#include <stdio.h>

namespace ciface
{
namespace OSX
{

class RemoteJoystick : public Core::Device
{
private:
	class Button : public Input 
	{
	public:
		std::string GetName() const;
		Button(std::string name, unsigned int m_server_socket, char* id) :  _sock(m_server_socket), _name(name), _id(id) {}
		ControlState GetState() const;
	private:
		const std::string _name;
		const unsigned int _sock;
		const char* _id;
	};

	class Axis : public Input
	{
	public:
		std::string GetName() const;
		Axis(std::string name, unsigned int m_server_socket, char* id);
		ControlState GetState() const;

	private:
		char* m_id;
		std::string m_name;
		double m_state;
		unsigned int _sock;

	};
	
public:
	bool UpdateInput() { return true; }
	bool UpdateOutput() { return true; }

	RemoteJoystick(int id);
	~RemoteJoystick();

	std::string GetName() const;
	std::string GetSource() const;
	int GetId() const;
private:
	int m_id;
    char* socket_name;
};

}
}
