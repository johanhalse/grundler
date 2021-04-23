# Grundler

The no-faff Ruby frontend bundler.

Now that all the evergreen browsers have support for JavaScript module loading, we can finally pretend like node.js never happened! Grundler is the sinecure for everyone who's sick to death of npm, yarn, babel, webpack, parcel, rollup, vite, fartspray, and snowpack. And I only made one of those up.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "grundler"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install grundler

## But we have enough package managers, please stop

Sorry! But Grundler fills one of the most _important niches_ in the Ruby ecosystem: MINE. Specifically, that would be the niche where I sit, precariously perched, cursing the bloat and complexity of node's module ecosystem, longing for the easy and carefree days of dropping a .js file into a "lib" folder and calling it a day. Seriously, we got ourselves into this hellscape just because we didn't think globals were enterprise-grade or whatever?! Like what were people even

## Alright, settle down, explain how it works

You've totally used a package manager before. You'll need to use one to install this one, in fact. So you probably know most of the stuff you need to know. Grundler, as a design goal, tries to 1) leverage the new browser-supported module format and 2) do as little as possible. You won't find any script sections or dev dependencies in its configuration. You can't run commands through it, shrinkwrap, or add prepublish steps. It'll only grab packages for you off npm's repository so you can use them and you should be damn well content with that.

## Please tell me you didn't invent a new configuration file though

I'm not below that sort of thing but no, it reads your `package.json` kind of like you'd expect. Grundler only bothers with the important part, the `{ "dependencies" }` section. If you expect it to also run your dev server or test suite or whatever, you will be disappointed. You might be disappointed anyway but I'd honestly prefer you at least be disappointed with the right things?

## So what actually happens when I add a package then

Grundler goes to everyone's favorite JavaScript repository, [npm](https://www.npmjs.com/), to look for the package you wanted to install. If it's found, it'll look up the most recent version, download its tarball, and analyze the JSON metadata to see if it uses the new ES module format. If it does, bingo, we can untar the module file _and only the module file_ to our dependency folder (currently called [nodules](https://twitter.com/hejsna/status/987043794427240448) because come on, it was **right there** but the node people were too buttoned-up I guess). This is cool because it's reminiscent of the old "go to someone's site and download a JS file" but structured and reproducible.

If the package you're trying to fetch isn't using ES module format though, you're in trouble.

## Trouble

Trouble. Grundler has a thing I've aptly named `CrapMode` that gets engaged whenever a package is using one of the old bothersome and browser-incompatible module formats (which, unfortunately, is pretty often). It will wrap the library in a simple little shim of sorts, to fool the module into believing it can hook into `module.exports` but AHA that's a honeypot we put there and then we can export. It's bound to fail in mysterious ways but it turns out there are a lot of packages that work just fine with it.

So you may get lucky. Or you may not. People have really been contorting themselves over the years doing weird shit to get their packages loading across the various formats the Internet has coughed up, and `module.exports` might not be a thing they use. Either way, if the package is one you really want, the responsible and adult thing to do is to go to their repository and help them out with a PR to convert to the new module format. Node has had support for quite a while, now browsers have it too — we're finally on track towards the compilation-free past/future again. Contribute and be part of it!

## And how do I use my freshly downloaded package again

You import it, like you would any file you wrote yourself. Look:

```bash
$ bundle exec grundle add three
Installing three 0.124.0
```

That should result in a file called `nodules/three.js`. That's your package, ready for pickup! Now, in order to import things in the browser, you need to opt in to the browser's module system by using `type="module"` in your script tag:

```html
<script src="main.js" type="module"></script>
```

And inside main.js you can do:

```javascript
import * as THREE from "./nodules/three.js";
console.log(THREE);
```

And if that thing is an ES module, or the CrapMode shim worked, you're good to go!

## That import statement though, slashes and stuff, ew

I hear you. It's not as pretty as just `from "three"`. People are working on this problem, with something called [import maps](https://github.com/WICG/import-maps). But it's not THAT ugly and look: the code is there. It can be loaded, just the way you'd expect if a teammate had written the code. You don't have npm's hundreds of megabytes of dep-tree lurking beneath the depths, ready to kneecap your CI system and bog down your builds. Let's hope we can all get back to the fairytale land of "it's just another file in your project". I'd even check the `nodules` folder in to your project if I were you — after all, in the end you're responsible for everything you ship, so why do we keep pretending our dependencies are this pristine thing, never to be touched?

## But I'm using TypeScript, if you just download the compiled and minified JS distribution I won't have my d.ts files and

Go away! Contemplate your life choices. I will have no truck with your transpiled abomination. The entire point of Grundler is to dramatically shorten the build chain, get back to just writing JS files, doing away with build servers and transpilation once and for all. Plus everyone knows TypeScript is just .NET wearing JavaScript's skin, ready to murder you in your sleep with a rictus grin on its rotting, lying face.

## Ok but what about deployment, won't this ruin my artisanal never-expiring cached CDN

Yes. I'm throwing my hands up here and again saying look, I'm sorry, but browsers don't do the import maps thing yet. And adding version numbers to downloaded libs would be murder on your actual source files: going through every file in your project that has `import * from thing-0.10.1.js` and replacing it with `thing-0.10.2.js` every time you bumped versions would absolutely SUCK.

You realistically have three options at this time:

1) Weep and use Webpack
2) Ditch your far-future cache and trust people's browsers to do the right thing
3) Use an import-aware fingerprint tool when building for production

## But... there IS no import-aware fingerprinting tool

Ha! Pop quiz, hotshot: what has two thumbs and has just written that kind of fingerprinting tool? It trawls a directory full of js files, copies them to md5-stamped files, and rewrites all import statements to use the stamped files. I'll put it up once it's been documented and more thoroughly tested. And once I've made sure it's actually a good idea.

Yes, yes, it's a build step, which makes me a little sad, but fingers crossed we can get rid of it when browsers have robust support for import maps. I bet the Babel crew have said something similar but then it kind of never happened and the tools got entrenched and suddenly everyone's stuck in the labyrinth with no way out and an angry minotaur belching somewhere behind them. But you can trust me! I'm a very honest-looking guy and I totally mean it: ship import maps and this won't be a problem anymore.

## Cool, how do I use Grundler then

Grundler tries its best to not do very much. No spiderweb of metadata or configuration, no weird executable sandbox things, and only four commands:

### Adding packages

Run `grundle add [list of packages]`. If you wanted to install, say, [three.js](https://github.com/mrdoob/three.js/) and [ky](https://github.com/sindresorhus/ky/) and have installed Grundler from your Gemfile it'd look like this:

```bash
bundle exec grundle add three ky
```

Grundler will go and find the latest version of those packages, install them, and add them to the `package.json` file.

### Installing from package.json

Once you've added a few packages, you can distribute the package.json and install using that, and Grundler will fetch the version specified. To install from package.json, run:

```bash
bundle exec grundle install
```

### Updating packages

Sometimes a package has been updated! To grab all the newest versions, run:

```bash
bundle exec grundle update
```

All your packages will be updated and written to package.json. You currently can't use the `update` command to update single packages, but Grundler is dumb enough that adding the packages again by running `add package1 package2` will do that for you.

### Removing packages

Tired of a package? No module export and CrapMode didn't work? Run:

```bash
bundle exec grundle remove packagename
```

It'll be removed from your nodules folder and your `package.json` file. Grundler will also get rid of any empty directories left after a removal.

## Configuration

There's only one configuration directive at this point and it's called `nodulePath`. Say you have all your JS source files in a directory called `src`. Then you might want your dependencies to live in `src/nodules`. Add the `nodulePath` directive to your package.json like so:
```json
{
  "dependencies": {},
  "nodulePath": "./src/nodules"
}
```

That'll make all of Grundler's operations work on that directory instead.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Testing is done with [Minitest](https://github.com/seattlerb/minitest) and mocking of npm is done with [webmock](https://github.com/bblimke/webmock). I initially wanted to use VCR for the JSON stubs but there seemed to be a lot of configuration and nothing worked and so I just put them there by hand and this is all TMI and never mind, there's like 200 lines of tests in a single file, you'll get the hang of it quickly.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/johanhalse/grundler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
