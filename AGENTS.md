# Build Instructions

## Development Build
To build the development version of the application (using the development manifest):
```bash
./scripts/build.sh --dev
```

## Production Build
To build the production version of the application:
```bash
./scripts/build.sh
```

## Running the Application
After building, you can run the application using:
```bash
flatpak run io.github.tobagin.Truco.Devel # For Dev
flatpak run io.github.tobagin.Truco       # For Prod
```
