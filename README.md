# YouDePP: YouTube Dependency Parsing Pipeline

## Pipeline

### Scraping Youtube channels

`scrape_yt.py` uses Selenium to scrape the video URLs and About page from one (or several) YouTube channels. 

#### Usage

To scrape one channel:

```{bash}
python3 scrape_yt.py [-h] [-g $GroupName] [--cutoff n] single $ChannelURL 
```

`$ChannelURL` should point to the channel's main page, e.g. https://www.youtube.com/c/ChannelNameHere.

To scrape multiple channels:

```{bash}
python3 scrape_yt.py [-h] [-g $GroupName] [--cutoff n] multi $FileName 
```

`$FileName` should be the path to a file containing a list of channel URLs, one URL per line.

By default, scraped video lists and About page info is saved in `corpus/channel_data/`. The optional argument `-g` or `--group` allows the user to specify an additional subfolder to group the output by (e.g. `corpus/channel_data/$GroupName`).

In addition, `--cutoff` allows the user to specify how many times the script should attempt to scroll down on the channel's video page, which loads additional videos. This option is useful for, e.g. very large channels, or if only recent videos are desired. If no cutoff value is specified, the page will be scrolled until all videos are loaded.

### Downloading captions and audio

`download_captions.py` downloads the caption tracks (and optionally, audio) from a list of YouTube videos. Additionally, this script generates a CSV file that includes metada for each scraped video, including its title, description, rating, tags, and so on.

Usage:

```{bash}
download_captions.py [-h] [--language LANGUAGE] [--group $GroupName] [--auto] [--audio]
                            [--titles] [--channels] [--srt] [--resume $n] [--limit $n]
                            $URLFile
```

`URLFile` should be a file containing a list of video URLs, one URL per line. Output from `scrape_yt.py` also includes the channel name (as it appears on the channel's page) and the channel's unique ID (as it appears in the channel's URL) and is tab-delimited; however, this information can be ommitted. Thus, the expected format of each line of the input file is as follows:

`$URL`

*or* 

`$URL\t$ChannelName$\t$ChannelID`

By default, all manually-created caption tracks will be downloaded. If a language (e.g. "English", "Korean") is specified with `--language` (or `-l`), only caption tracks that include this language in their name will be downloaded. To include automatic captions, as well, the flag `-a` or `--auto` can be used.

To download audio in addition to captions, include the flag `--audio` or `-s` (for "sound").

Caption tracks are saved to the folder `corpus/raw_captions/$language`, where `$language` is the track's language code (e.g. `en`). Automatic captions have an `a` prepended to their language codes; for example, `a.en` would be the code for automatically-generated English caption tracks. Caption tracks default to XML format, but SRT format is also available via the `--srt` flag.

Audio tracks are saved to `captions/raw_audio/`. Both caption tracks and audio tracks will use `$ChannelName_$n` as their filenames, where `$ChannelName` is the name of the video's author (as determined by `pytube`) and `n` is the index of the video (indexed by-channel). The flag `--titles` can be used to have video titles be included in the filenames, as well (e.g. `$ChannelName_$n_$VideoTitle`). (**Note:** Currently, due to the behaviour of `pytube`, caption tracks are also suffixed with the captions' language code, but this should change in the near future.)

As with `scrape_yt.py`, a "group" can be additionally specified in order to organize tracks within an additional subfolder, e.g. `corpus/raw_captions/$GroupName`. Regardless of group, tracks can be further organized into subfolfers by channel by specifying `--channels`. 

For very large lists of videos, `--resume` and `--limit` can be used to resume from the Nth video and limit processing to N total videos, respectively.

### Automatically cleaning caption files

Documentation coming soon!

### Parsing caption files

Documentation coming soon!
