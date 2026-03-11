# MCP Genmedia Servers

This DevContainer feature installs the MCP Genmedia servers and the Gemini CLI.

## Included Tools

- **mcp-avtool-go**: Audio/Video manipulation tools (requires ffmpeg/ffprobe).
- **mcp-chirp3-go**: Text-to-Speech synthesis.
- **mcp-gemini-go**: Multimodal Gemini interface.
- **mcp-imagen-go**: Image generation with Imagen 3.
- **mcp-lyria-go**: Music generation with Lyria.
- **mcp-veo-go**: Video generation with Veo 2.
- **Gemini CLI**: An AI agent that can be used with these MCP servers.

## Configuration

The feature configures the Gemini CLI to use the installed MCP servers. By default, it looks for the following environment variables:

- `PROJECT_ID`: Your Google Cloud Project ID.
- `GENMEDIA_BUCKET`: The GCS bucket for media output.

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `installAll` | boolean | `false` | Install all Genmedia MCP servers. |
| `installAvtool` | boolean | `true` | Install mcp-avtool-go. |
| `installChirp` | boolean | `false` | Install mcp-chirp3-go. |
| `installGemini` | boolean | `false` | Install mcp-gemini-go. |
| `installImagen` | boolean | `false` | Install mcp-imagen-go. |
| `installLyria` | boolean | `false` | Install mcp-lyria-go. |
| `installVeo` | boolean | `false` | Install mcp-veo-go. |
