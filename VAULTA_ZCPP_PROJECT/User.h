#pragma once
#include <string>

using namespace std;

class User
{
private:
	int m_id;
	string m_name, m_surname, m_role, m_password;

public:
	User();
	User(int userId, string userName, string userSurname, string role, string password)
		: m_id(userId), m_name(userName), m_surname(userSurname), m_role(role), m_password(password) {}

	int getUserId() const;
	string getUserName() const;
	void setUserName(string name);
	string getUserSurname() const;
	void setUserSurname(string surname);
	string getRole() const;
	void setRole(string role);
	string getPassword() const;
	void setPassword(string password);
};

