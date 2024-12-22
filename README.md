# Planet - Boilerplate

To start your Phoenix server:

  * Make sure to update the folder name to your project name.
  * [Optional]: Run `setup.sh` if you would like to cleanup dependencies.
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Notes

```
DATABASE_URL=postgresql://shapathneupane@127.0.0.1/send_inspector_prod3 SECRET_KEY_BASE=4gX34ebM1uwPeF6rvo/w/5fERI7zBMr9p9JvtlFi9gNH5rMrBEJSLrAoJbDwCxPS PHX_HOST=sendinspector.com ./server
```

If *SQLite* is used; need to change the migration file from 

`add :email, :citext, null: false`
to 
`add :email, :string, collate: :nocase` 


### Dializer or Formatter Error
rm -r ~/.hex/cache.ets
rm -r .elixir_ls/
rm -r _build/


# TODO

