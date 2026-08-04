+++
date = '2026-08-04T14:40:47+02:00'

[build]
  list = 'local'
  render = 'never'
+++

In 2022 I started using newsboat as a RSS feed reader, initially to follow graphics programming blogs but I later expanded it to youtube channels and podcasts and other things I felt worth following. The main way I used newsboat was to break up each feed into it's own seperate main section, sorted by which had the latest item. This kept it a lot tidier than something like email where everything is interlaced and youtube channels that upload twice a day are mixed in with blog posts that come out once every 2 months. I could also colour code these for easy identication - youtube channels are red, podcasts are green, etc. It helps to recognize things faster than having to activate the text reading part of your brain.

I switched to NixOS on my laptop in 2023 and slowly converted my increasingly complex newsboat set into something that was generated from a .nix file. More advanced features of newsboat include being able to combine multiple feeds into a single section (useful for following people who have both a blog and a podcast), as well as filtering items out of feeds (getting rid of youtube shorts, for example). With nix-on-droid I copied this setup onto my phone and that ended up being the primary way I got updated.

Eventually though this setup broke under it's complexibility and number of moving parts and simply was just too slow and prone to crashing. I decided to write my own system and now use a dedicated android app for this. I'll specify the design here but presently leave the implementation an an exercise for the reader (or LLM). If you nag me hard enough I might open source the core parts.

The main thing is that you have a json file. This consists of 2 items, `sources` and `lists`. `sources` is a list of all source urls, either atom or rss. On fetch, all these feeds are fetched and their items inserted into a sqlite database. I also have the ability to specify a wasi wasm program that the data from the feed is passed through to either modify a feed or produce a feed from non-rss content, but I only use this in a few cases and it can generally be skipped. `lists` is a list of feeds, with a colour, title and SQL clause, generally like `feed_source == "..."`. When displaying a list, `select id, feed_source, feed_title, link, title, pub_date, read, saved, media_url from items where {clause} order by datetime(pub_date) desc` is run. When displaying all the lists, a huge query like this is run:

```
select max(pub_date), count(*), sum(read) from items where {clause_1}
...
union
select max(pub_date), count(*), sum(read) from items where {clause_2}
...
order by max(pub_date) desc
```

Feeds are only refreshed when a 'Refresh All' button is pressed. The `saved` field of items is useful as it means I can have a feed consisting of all items I've saved.

I've found this setup to be incredible versatile and does everything I need without much faff. I'm still using nixos to generate the .json file and update that frequently, but I'm not sure if I touched the app this year at all.
