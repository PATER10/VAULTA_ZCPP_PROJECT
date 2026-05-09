#include "User.h"

User::User()
{
}

int User::getUserId() const
{
	return m_id;
}

string User::getUserName() const
{
	return m_name;
}

void User::setUserName(string name)
{
	m_name = name;
}

string User::getUserSurname() const
{
	return m_surname;
}

void User::setUserSurname(string surname)
{
	m_surname = surname;
}

string User::getRole() const
{
	return m_role;
}

void User::setRole(string role)
{
	m_role = role;
}

string User::getPassword() const
{
	return m_password;
}

void User::setPassword(string password)
{
	m_password = password;
}
