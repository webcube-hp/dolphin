// Copyright 2013 Dolphin Emulator Project
// Licensed under GPLv2
// Refer to the license.txt file included.

#include <sstream>

#include <Foundation/Foundation.h>

#include "InputCommon/ControllerInterface/OSX/OSXRemoteJoystick.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <streambuf>
#include <istream>
#include <ostream>
#include <stdlib.h>

namespace ciface
{
namespace OSX
{


RemoteJoystick::RemoteJoystick(int pid)
{
	m_id = pid;
	// std::stringstream ss;
	// ss << "/tmp/data1.sock";
	socket_name = (char*)malloc(200);
	std::sprintf(socket_name,"/tmp/p%d.sock", pid);

 	struct sockaddr_un server_addr;

    // setup socket address structure
    bzero(&server_addr,sizeof(server_addr));
    server_addr.sun_family = AF_UNIX;
    strncpy(server_addr.sun_path, socket_name, sizeof(server_addr.sun_path) - 1);

    unsigned int m_server_socket = socket(PF_UNIX,SOCK_STREAM,0);
    if (!m_server_socket) {
        perror("socket");
        exit(-1);
    }

    // connect to server
    if (connect(m_server_socket,(const struct sockaddr *)&server_addr,sizeof(server_addr)) < 0) {
        perror("connect");
        exit(-1);
    }


	AddInput(new Button("a", m_server_socket, "0")); // A
	AddInput(new Button("b", m_server_socket, "1")); // B
	AddInput(new Button("x", m_server_socket, "2")); // x
	AddInput(new Button("r", m_server_socket, "3")); // r
	AddInput(new Button("z", m_server_socket, "4")); // z
	AddInput(new Button("s", m_server_socket, "5")); // s

	// joystick
	AddInput(new Button("X+", m_server_socket, "6")); // s
	AddInput(new Button("X-", m_server_socket, "7")); // s
	AddInput(new Button("Y+", m_server_socket, "8")); // s
	AddInput(new Button("Y-", m_server_socket, "9")); // s


	// AddAnalogInputs(new Axis("X+", m_server_socket, "6"), new Axis("X-", m_server_socket,"8"));
	// AddAnalogInputs(new Axis("Y+", m_server_socket, "9"), new Axis("Y-", m_server_socket,"10"));
}

RemoteJoystick::~RemoteJoystick()
{
	return;
}

std::string RemoteJoystick::GetName() const
{
	return "Remote Joystick";
}

std::string RemoteJoystick::GetSource() const
{
	return "Remote Controller";
}

int RemoteJoystick::GetId() const
{
	return m_id;
}

ControlState RemoteJoystick::Button::GetState() const
{
	// std::cout << "test";
	int n = write(_sock,_id,1);
	char* recvData = new char[1024];
	recv(_sock, recvData, 1, 0);
	// std::cout << (double)(recvData[0]) << std::endl;
	return (double)(recvData[0]);
	// return m_state;
}

std::string RemoteJoystick::Button::GetName() const
{
	return std::string("Button ") + _name;
}

RemoteJoystick::Axis::Axis(std::string name, unsigned int m_server_socket, char* aid)
{		
	m_id = aid;
	_sock = m_server_socket;
	m_name = std::string("Axis ") + name;
}

ControlState RemoteJoystick::Axis::GetState() const
{	
	// std::cout << "test";
	int n = write(_sock,m_id,1);
	char* recvData = new char[1024];
	// int rcv = 0;
	// while(rcv != 8) {
	// 	rcv += recv(_sock, &recvData[rcv], 8, 0);
	// }	
	recv(_sock, recvData, 1, 0);
	std::cout << (double)recvData[0] << std::endl;
	return (double)recvData[0];
}

std::string RemoteJoystick::Axis::GetName() const
{
	return m_name;
}


}
}
