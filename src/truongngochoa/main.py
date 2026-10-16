import sys


def main() -> None:
    arguments = list(sys.argv[1:])
    if arguments and arguments[0] in {
        "--omnivoice-worker",
        "--omnivoice-server",
    }:
        from truongngochoa.pipeline.omnivoice_tts import main as omnivoice_main

        raise SystemExit(omnivoice_main(arguments))

    from truongngochoa.desktop.main import main as desktop_main

    desktop_main()


if __name__ == "__main__":
    main()
