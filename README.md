
#### Initial dev env ####

Install requirements:

**Ruby / Sass**

You can install Ruby through the apt package manager, rbenv, or rvm.
Install Sass through your **Terminal or Command Prompt**.

```
gem install sass scss-lint
export PATH="~/.gem/ruby/2.1.0/bin:$PATH"
sass -v             # should return Sass 3.3.8 (Maptastic Maple)
```

Complete process for all OS at: http://sass-lang.com/install

**Node + Gulp**

We recommend using [nvm](https://github.com/creationix/nvm) to manage different node versions
```
npm install -g gulp
npm install
gulp
```

And go in your browser to: http://localhost:9001/

#### E2E test ####

If you want to run e2e tests

```
npm install -g protractor
npm install -g mocha
npm install -g babel@5

webdriver-manager update
```

To run a local Selenium Server, you will need to have the Java Development Kit (JDK) installed.

## Tests ##

#### Unit tests ####

- To run **unit tests**

  ```
  gulp
  ```
  ```
  npm test
  ```

#### E2E tests ####

- To run **e2e tests** you need running and

  ```
  gulp
  ```
  ```
  webdriver-manager start
  ```
  ```
  protractor conf.e2e.js --suite=auth     # To tests authentication
  protractor conf.e2e.js --suite=full     # To test all the platform authenticated
  ```
