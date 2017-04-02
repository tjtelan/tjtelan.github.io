---
layout: post
tags: [musing, maven, gulpjs, build]
---
I do a lot of devops automation for work. This gives me a lot of opportunity to touch the build systems of many different languages. I have a professional background with Python, and a lot of experience building C/C++ with make.

I most recently got to play with Java/Maven, and NodeJS/Gulp.

--

The project I was building has a UI written in node, and built into an npm module with gulp. There are also maven pom files that describe the build with gulp using npm run build. This was done so everything could be orchestrated for building into a java jar.

Things I thought were neat about maven is the plugin system.

I'm not a huge fan of the pom files using xml, but it is really nice to be able to configure dependencies, and dynamically define build artifacts. The local maven repo is still a little confusing at times, but with more time I think it'll make more sense.

--

The UI build with gulp was more unfamiliar. The build instructions are in javascript, naturally. You can use gulp.task() and define a list of dependencies. But I had some experiences where my dependency lists were not made explicit enough. I suppose this is not much different than makefiles.
