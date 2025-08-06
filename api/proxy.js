export default async function handler(req, res) {
  const { url } = req.query;
  if (!url) {
    return res.status(400).json({ error: "Missing 'url' query parameter." });
  }

  try {
    const response = await fetch(url);
    if (!response.ok) {
      return res.status(500).json({ error: "Failed to fetch the image." });
    }

    res.setHeader("Content-Type", response.headers.get("content-type"));
    const buffer = await response.arrayBuffer();
    res.send(Buffer.from(buffer));
  } catch (err) {
    res.status(500).json({ error: "Proxy error: " + err.message });
  }
}
