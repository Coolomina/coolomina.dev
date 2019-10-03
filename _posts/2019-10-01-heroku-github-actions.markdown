---
layout: post
title:  "Deploying your site with Heroku and GitHub Actions"
categories: []
---

> Hey!, you can apply to the [GitHub Actions](https://github.com/features/actions) beta!

![](https://gallery.mailchimp.com/9d7ced8c4bbd6c2f238673f0f/images/4a0fe48b-9c18-4a86-a9fd-6427c1322478.png)


### GitHub Actions
Fellas, the GitHub CI/CD has arrived, and with it, lots of *GitHub Actions vs (NAME YOUR CI)* "articles" on the Internet. The main difference I've seen so far with the rest of CI/CD providers is that GitHub gives us the `action` interface, that will allow us to configure a third party service saving us from the pain of configuration, scaffolding and installation steps. We'll be using Heroku's for this quick blog post.

Go!

### First, our artifact
I personally hate local installing all the ~~derpendencies~~ dependencies that come with a project and it's always good to have an infrastructure agnostic deployable artifact. So let's containerize stuff! 🐋

#### json-server
Amazing library. I'm not into all the JS hype, but I have to give credit to the creators of this tooling for mocking a full REST API with a single JSON file. It goes like this.

`dumb.json`
{% highlight javascript %}
{
  "flipaos": [
    { "id": 1, "name": "omars", "location": "ES" },
    { "id": 2, "name": "deivids", "location": "ES" },
    { "id": 3, "name": "paks", "location": "ES" },
    { "id": 4, "name": "FJL", "location": "ES" },
    { "id": 5, "name": "anduan", "location": "ES" },
    { "id": 6, "name": "FV", "location": "ES" },
    { "id": 7, "name": "eidrien", "location": "UK" },
    { "id": 8, "name": "coolomain", "location": "ES" }
  ]
}
{% endhighlight %}

`Dockerfile`
{% highlight Dockerfile %}
FROM node:12.10.0-stretch-slim
RUN npm install -g json-server@0.15.1
COPY dumb.json /server/
RUN echo "Before you give me shit: https://devcenter.heroku.com/articles/dynos#web-dynos"

CMD ["sh", "-c", "json-server /server/dumb.json --host 0.0.0.0 --port $PORT"]
{% endhighlight %}

And just like that we have a REST API with the data of `dumb.json` available at `http://localhost:$PORT`. Let's pretend that's our containerized service.


### Let's ship it!
Sweet. We already have our artifact clean, tidy and ready to be pushed to a registry. The next step is to automate its way into it. Let's take a look at Heroku's [action](https://github.com/actions/heroku), which seems to be a dockerized wrapper of the Heroku CLI.

> An `action` is basically a wrapper container for scaffolding dependencies.

First, we'll need to properly name our job and define the policies by which it's triggered. Also, any secrets we want to make available in all steps at build time must be specified aswell. [Link for the lazy like *moi*](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables). Also, we'll build only master for now.

{% highlight YAML %}
name: Docker Image CI

on:
  push:
    branches:
    - master
env:
  HEROKU_API_KEY: {% raw %} ${{ secrets.HEROKU_API_KEY }} {% endraw %}
{% endhighlight %}

Defining on what runtime your jobs will run is also important. Here's a full list of [available virtual host machines](https://help.github.com/en/articles/workflow-syntax-for-github-actions#jobsjob_idruns-on) in case you're interested, it includes Ubuntu and both Windows and ¡Mac!, very interesting for those who'll want to control the lifecycle of an iOS artifact (these are not very common as you need a dedicated MacOS VM/metal). We'll be using Ubuntu.

{% highlight YAML %}
jobs:
  release:
    runs-on: ubuntu-16.04
{% endhighlight %}

One of the predefined actions we'll have available through the build is the `checkout`, obviously essential in any CI/CD pipeline. Some Dockerfile linting always keeps us from *hacking ourselves* into thinking we're applying best practices. 

{% highlight YAML %}
    steps:
    - uses: actions/checkout@v1
    - name: Docker linting
      run: docker run --rm -i hadolint/hadolint < Dockerfile
{% endhighlight %}

Finally, the Heroku action that will take as arguments anything acceptable by the Heroku CLI, like seen in [its docs](https://devcenter.heroku.com/articles/container-registry-and-runtime#getting-started). If we take a closer look at the Docker entrypoint of this `action`, we can see it's just a wrapper for the CLI itself. [Link](https://github.com/actions/heroku/blob/master/entrypoint.sh).

{% highlight YAML %}
    - name: Heroku login
      uses: actions/heroku@1.0.0
      with:
        args: container:login
    - name: Heroku push
      uses: actions/heroku@1.0.0
      with:
        args: container:push -a dummy-container web
    - name: Heroku release
      uses: actions/heroku@1.0.0
      with:
        args: container:release -a dummy-container web
{% endhighlight %}

> Very interesting article about designing [12-Factor CLI apps](https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46), by Jeff Dickey

### What now?
What do you mean with that _What now?_ face?, your site is live!, go play with the actions and hopefully contribute to the ecosystem so everyone can use your knowledge in their projects :)

### Useful links

- [Final YML](https://github.com/Coolomina/GitHeroku-actions/blob/master/.github/workflows/release_artifact.yml)
- [Pipeline](https://github.com/Coolomina/GitHeroku-actions/runs/246856716)