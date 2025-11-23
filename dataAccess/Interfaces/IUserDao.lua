local class = require "middleclass"

IUserDao = class('IUserDao')

function IUserDao:GetUsers() print("not implemented") end

function IUserDao:GetUserById() print("not implemented") end

function IUserDao:CreateUser(name) end