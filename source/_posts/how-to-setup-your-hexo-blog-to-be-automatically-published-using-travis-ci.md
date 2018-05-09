title: How to setup your hexo blog to be automatically published using Travis CI
date: 2018-05-09 15:31:27
tags:
- travis
- hexo
- GitHub Pages
---

[GitHub Pages has recently finished one of the long standing feature requests of
allowing SSL on custom domains!](https://blog.github.com/2018-05-01-github-pages-custom-domains-https/).
I have it enabled on my blog (https://minhajuddin.com). Yay! However, I have not
been able to publish any new blog posts because the effort required to publish
a new post is a bit too much! The previous service that I had used to auto publish
was shut down. And looking at the alternatives, [Travis CI](https://travis-ci.org/minhajuddin/blog.minhajuddin.com) looked great.
I use it for a few of my other projects.

Here is the `.travis.yml` with a few slight modifications from: https://github.com/jkeylu/deploy-hexo-site-by-travis-ci/blob/master/_travis.yml

```
# Deploy hexo site by travis-ci
# https://github.com/jkeylu/deploy-hexo-site-by-travis-ci
# 1. Copy this file to the root of your repository, then rename it to '.travis.yml'
# 2. Replace 'YOUR NAME' and 'YOUR EMAIL' at line 29
# 3. Add an Environment Variable 'DEPLOY_REPO'
#     1. Generate github access token on https://github.com/settings/applications#personal-access-tokens
#     2. Add an Environment Variable on https://travis-ci.org/{github username}/{repository name}/settings/env_vars
#         Variable Name: DEPLOY_REPO
#         Variable Value: https://{githb access token}@github.com/{github username}/{repository name}.git
#         Example: DEPLOY_REPO=https://6b75cfe9836f56e6d21187622730889874476c23@github.com/jkeylu/test-hexo-on-travis-ci.git
# 4. Make sure Travis is configured to hide your Variable, else others will see your access token and can mess with all your repos.

language: node_js
node_js:
- "9"

branches:
  only:
  - master

install:
- npm install

before_script:
- git config --global user.name 'Khaja Minhajuddin'
- git config --global user.email 'minhajuddin.k@gmail.com'

script:
- ./node_modules/.bin/hexo generate

after_success:
- mkdir .deploy
- cd .deploy
- git clone --depth 1 --branch gh-pages --single-branch $DEPLOY_REPO . || (git init && git remote add -t gh-pages origin $DEPLOY_REPO)
- rm -rf ./*                      # Clear old verion
- cp -r ../public/* .             # Copy over files for new version
- git add -A .
- git commit -m 'Site updated'    # Make a new commit for new version
- git branch -m gh-pages
- git push -q -u origin gh-pages  # Push silently so we don't leak information

```
