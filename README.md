# AutoBot Pro

Automation layer for a white-label deployment based on Typebot `v2.28.2`.

## License

The pinned upstream `v2.28.2` source is verified by CI to contain the GNU Affero General Public License. This repository does **not** replace, remove, or rewrite the upstream LICENSE/copyright notices. Review the complete upstream license and notices before commercial distribution.

## Repository contents

- `setup-autobot.sh` — reproducible checkout/customization bootstrap.
- `docker-compose.prod.yml` — PostgreSQL, Redis, MinIO, Builder, Viewer and Nginx.
- `.env.example` — production configuration template.
- `deploy.sh` — Ubuntu Docker bootstrap and deployment.
- `nginx/autobotpro.conf` — reverse-proxy template.
- `.github/workflows/build-aab.yml` — pinned-source Android wrapper build.

## One-click VPS deployment

Use the script only after reviewing it and after preparing DNS for the builder/viewer hostnames:

```bash
curl -fsSL https://raw.githubusercontent.com/nguyenxuandat20091985-rgb/AutoBot-Pro/main/deploy.sh | sudo bash
```

The first run creates `/opt/autobotpro/.env` from `.env.example`. Edit that file with strong secrets and real domains before starting the production stack.

## GitHub Actions Android build

Create repository variable `AUTOBOT_WEB_URL`, for example `https://admin.example.com`. Every push to `main` runs the workflow. The result is an artifact named `autobot-pro-aab` containing `app-release.aab`.

For Google Play production signing, configure a protected Android keystore and signing secrets before publishing. The default workflow deliberately does not embed a private signing key in Git.

## Important production notes

The Docker images in `docker-compose.prod.yml` point at the upstream Typebot 2.28.2 images. A true white-label production image must be built from the customized source and published to a registry you control; change the image references before treating the stack as the final commercial deployment.
