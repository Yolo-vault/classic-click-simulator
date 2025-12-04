local AdminConfig = {}

AdminConfig.Admins = {
	[4601809587] = true, -- Halls
	-- [000000000] = true — adicionar mais IDs aqui
}

function AdminConfig.IsAdmin(userId: number): boolean
	return AdminConfig.Admins[userId] == true
end

return AdminConfig
