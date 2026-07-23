//help there's nobody on
client/verb/singleplayerpopup()
	set hidden = 1
	set name = "singleplayerpopup"
	src.Browse( {"<h3>Hey wait a minute, where are the players?</h3>
			<p>That's a very fair question! Sustained population is a chicken and egg situation, unfortunately. Without coordination, everyone keeps missing each other, passing like ships in the night.</p>
			<p>You're doing your part by being here, but you still need someone to play with! So that means:</p>
		<h3>Don't be afraid to AHELP (F1) or MENTORHELP (F3) for players!</h3>
			<p>We're always listening to messages that come in, whether that's a question about the game.</p>
			<p>A request for others to play or give you a tour is our favorite kind of message to receive. The <a href="https://discord.com/invite/Xh3yfs8KGn">discord</a> is full of people who will connect the moment there's someone eager to play. Eventually, it will be self-sustaining.</p>
			<p>We love meeting new people! Bring your SS13-playing friends!</p>
		<h3>We also have scheduled playtimes, primarily Sunday evening around 6 PM Eastern.</h3>
	</ul>"}, "window=singleplayer;title=Where Is Everyone??" )
	return
