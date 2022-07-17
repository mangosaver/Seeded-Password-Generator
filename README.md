# Seeded Password Generator

## About

This project takes a process I previously used (creating passwords by adding the site name to the end of a master password) and goes one step further, by hashing a user-specified master password with a site name. A private, randomly generated salt (the "seed") is used to create a pseudorandom string. It's important to note that there is just one, never-changing salt used for every hashing operation. This system is not recommended as a serious alternative to existing password management services.

Generated passwords are not stored. The only "state" is a map of IP addresses to a list of request timestamps (for rate limiting purposes) and the random salt itself. It is built with [Elixir](https://elixir-lang.org/), as a server with a web interface for generating passwords. There is no strong reason for using Elixir, other than that I wanted to try it out. The hashing itself is done through [Bcrypt](https://en.wikipedia.org/wiki/Bcrypt), a secure, slow hashing function.

The frontend is static web content, served by [plug_cowboy](https://github.com/elixir-plug/plug_cowboy). For consistency across browsers, [sanitize.css](https://github.com/csstools/sanitize.css) is used. The [bcrypt_elixir](https://hexdocs.pm/bcrypt_elixir/Bcrypt.html) library is used to implement the hashing.

## Usage Guide

If a valid salt is not specified in priv/salt.txt, one will be generated upon startup. To generate a new salt, you can delete the file completely, or simply erase the contents. The salt should be kept secret; if it is found, the security of the system is greatly reduced.

To run the project, [install Elixir](https://elixir-lang.org/install.html) and run:

`mix deps.get`

Followed by:

`mix run --no-halt`

Rate limiting settings can be changed in ip_conn_state.ex, by modifying the following constants:

```Elixir
@max_reqs_per_period 3
@period_ms 4_000
```
In the above example, the acceptable request rate is 3 requests per 4 seconds.

## Live Demo

A live demo of the project is available [here](http://82.180.139.239:4000/pub/main.html).

## Troubleshooting

On some Linux distributions, there aren't up-to-date packages available for Erlang and Elixir. I'd recommend using [asdf](https://asdf-vm.com/) for installation and management.

## Future Work

It would be good to have some scheduled process clear out old map entries, in order to reduce the memory footprint if it were to accumulate over time.

Generating temporary QR codes so that a password generated on one device could be accessed on another would also be a nice quality of life feature.