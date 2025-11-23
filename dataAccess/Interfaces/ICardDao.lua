local class = require "middleclass"

ICardDao = class('ICardDao')

function ICardDao:GetCards() error("not implemented") end

function ICardDao:GetCardById() error("not implemented") end

function ICardDao:CreateCard(name, printing, set, number) error("not implemented") end