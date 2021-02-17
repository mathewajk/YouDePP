# YouDePP: YouTube Dependency Parsing Pipeline

## Pipeline

### Scraping Youtube channels

#### Dependencies

##### Selenium

[Selenium](https://www.selenium.dev/) is a browser automation tool. The Selenium documentation can be found [here](https://www.selenium.dev/documentation/).

In order to work with Selenium, you will first need to install it with `pip` via `pip install selenium` or `pip3 install selenium`. You will also need to download a WebDriver:

- For Firefox: [GeckoDriver](https://github.com/mozilla/geckodriver/releases)
- For Chrome: [ChromeDriver](https://github.com/SeleniumHQ/selenium/wiki/ChromeDriver)

The driver should be placed somewhere in your path (e.g. `/usr/local/bin/`). MacOS users can also download these drivers via [Homebrew](https://brew.sh/), which will place the driver in your `Cellar`.

`scrape_yt.py` uses [Selenium](https://www.selenium.dev/documentation/) to scrape the video URLs and About page from one (or several) YouTube channels. Currently, the script assumes the use of Firefox + Geckodriver, though it is possible to modify `scrape_yt.py` to use Chrome instead. (Official support coming at some point.)

#### Usage

To scrape one channel:

```{bash}
python3 scrape_yt.py [-h] [-g $GroupName] [--cutoff $N] single $ChannelURL
```

`$ChannelURL` should point to the channel's main page, e.g. `https://www.youtube.com/channel/ChannelNameHere`.

To scrape multiple channels:

```{bash}
python3 scrape_yt.py [-h] [-g $GroupName] [--cutoff $N] multi $FileName
```

`$FileName` should be the path to a file containing a list of channel URLs, one URL per line.

By default, scraped video URLs and About pages are saved in `corpus/channel_data/`. The optional argument `-g` or `--group` allows the user to specify an additional subfolder to group the output by (e.g. `corpus/channel_data/$GroupName`).

In addition, `--cutoff` allows the user to specify how many times the script should attempt to scroll the channel's video page, which loads additional videos. This option is useful for, e.g. very large channels, or if only recent videos are desired. If no cutoff value is specified, the page will be scrolled until all videos are loaded.

### Downloading captions and audio

#### Dependencies

##### Pytube

`pytube` can be installed via `pip`, e.g. `pip install pytube` or `pip3 install pytube`.

#### Usage

```{bash}
download_captions.py [-h] [--language $Language] [--group $GroupName] [--auto] [--audio]
                            [--titles] [--channels] [--srt] [--resume $N] [--limit $N]
                            $URLFile
```

`$URLFile` should be a file containing a list of video URLs, one URL per line. Output from `scrape_yt.py` also includes the channel name (as it appears on the channel's page) and the channel's unique ID (as it appears in the channel's URL) alongeside each URL and is tab-delimited. If this additional information is ommitted, video authors (that is, channels) will be determined via `pytube`. (**Warning:** Channel names as determined by `pytube` are not necessarily unique; leaving "channel name" and "channel ID" unspecified may result in data being overwritten.)

To summarize, the expected format of each line of the input file is as follows:

`$URL\n`

*or*

`$URL\t$ChannelName$\t$ChannelID\n`

By default, all manually-created caption tracks will be downloaded. If a language (e.g. "English", "Korean") is specified with `--language` (or `-l`), only caption tracks that include this language in their name will be downloaded. To include automatic captions, as well, the flag `-a` or `--auto` can be used.

To download audio in addition to captions, include the flag `--audio` or `-s` (for "sound").

Caption tracks are saved to the folder `corpus/raw_captions/$language`, where `$language` is the track's language code (e.g. `en`). Automatic captions have an `a` prepended to their language codes; for example, `a.en` would be the code for automatically-generated English caption tracks. Caption tracks default to XML format, but SRT format is also available via the `--srt` flag.

Audio tracks are saved to `captions/raw_audio/`. Both caption tracks and audio tracks will use `$ChannelName_$n` as their filenames, where `$ChannelName` is the name of the video's author (as determined by `pytube`) and `n` is the index of the video (indexed by-channel). The flag `--titles` can be used to have video titles be included in the filenames, as well (e.g. `$ChannelName_$n_$VideoTitle`). (**Note:** Currently, due to the behaviour of `pytube`, caption tracks are also suffixed with the captions' language code, but this should change in the near future.)

As with `scrape_yt.py`, a "group" can be specified in order to organize tracks within an additional subfolder, e.g. `corpus/raw_captions/$GroupName`. Regardless of group, tracks can be further organized into subfolfers by channel by specifying `--channels`.

For very large lists of videos, `--resume` and `--limit` can be used to resume from the Nth video and limit processing to N total videos, respectively.

### Automatically cleaning caption files

Documentation coming soon!

### Parsing caption files

Documentation coming soon!
