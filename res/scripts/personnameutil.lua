local indonesianData = {
	english = {
		firstNamesMale = {
			"Ahmad", "Budi", "Cahyo", "Dedi", "Eko", "Fajar", "Guntur", "Hery", "Iwan", "Joko",
			"Kurniawan", "Lukman", "Mulyono", "Nugroho", "Oscar", "Putu", "Qomar", "Rian", "Slamet", "Taufik",
			"Utomo", "Victor", "Wahyu", "Xaverius", "Yudi", "Zainal", "Aditya", "Bambang", "Chandra", "Doni",
			"Edy", "Farhan", "Gilang", "Hendra", "Indra", "Jaka", "Kevin", "Lutfi", "Mahendra", "Nanda",
			"Oky", "Pandu", "Rizky", "Saputra", "Tegar", "Untung", "Vino", "Wisnu", "Yuda", "Zaki",
			"Agus", "Andi", "Bayu", "Darma", "Darmawan", "Fahmi", "Hafiz", "Ilham", "Imam", "Irwan",
			"Johan", "Krisna", "Naufal", "Prabowo", "Rangga", "Ridwan", "Rudi", "Satrio", "Surya", "Yusuf",
			"Zulfikar",
		},
		firstNamesFemale = {
			"Ani", "Bunga", "Citra", "Dewi", "Endah", "Fitri", "Gita", "Hana", "Indah", "Julia",
			"Kartika", "Lestari", "Maya", "Nining", "Olivia", "Putri", "Qoriah", "Ratna", "Siti", "Tini",
			"Utami", "Vera", "Wati", "Xena", "Yanti", "Zaskia", "Ayu", "Bella", "Cindy", "Dian",
			"Elisa", "Febri", "Gisela", "Hesti", "Ika", "Jeni", "Kania", "Lia", "Mila", "Novi",
			"Okta", "Puspita", "Rina", "Sari", "Tiara", "Uli", "Vivi", "Wanda", "Yuni", "Ziva",
			"Aisyah", "Alya", "Anisa", "Dinda", "Farah", "Fitria", "Hilda", "Intan", "Jasmine", "Kirana",
			"Laila", "Nadia", "Nissa", "Rani", "Salsa", "Sania", "Siska", "Syifa", "Tasya", "Zahra",
		},
		lastNames = {
			"Wijaya", "Kusuma", "Saputra", "Pratama", "Setiawan", "Hidayat", "Santoso", "Susanto", "Gunawan", "Budiman",
			"Hartono", "Salim", "Widjaja", "Tan", "Lim", "Wong", "Simanjuntak", "Nasution", "Siregar", "Pane",
			"Lubis", "Ginting", "Karo-karo", "Sembiring", "Tarigan", "Perangin-angin", "Manik", "Situmorang", "Hutagalung",
			"Pardede", "Tampubolon", "Silalahi", "Simamora", "Marbun", "Sinaga", "Purba", "Saragih", "Damanik", "Sumbayak",
			"Sitorus", "Pohan", "Pasaribu", "Hasibuan", "Harahap", "Ritonga", "Batubara", "Daulay", "Matondang", "Rajagukguk",
			"Prasetyo", "Wibowo", "Kusnadi", "Kusnandar", "Handoko", "Iskandar", "Fauzi", "Maulana", "Halim", "Kurnia",
			"Sapri", "Suryadi", "Sutanto", "Suryanto", "Rahman", "Hasan", "Fadli", "Ramadhan", "Pranoto", "Anggraini",
		},
	}
}

local names = {
	indonesia = indonesianData,
}

-- Fallback: Jika ada script (bawaan game) mencari negara lain, arahkan ke Indonesia
setmetatable(names, {
	__index = function(t, key)
		return indonesianData
	end
})

return names
