import { useState } from 'react'
import { uploadMarkdown } from '../api'

type Props = {
  user: string | null
}

export default function UploadBox({ user }: Props) {
  const [file, setFile] = useState<File | null>(null)
  const [isUploading, setIsUploading] = useState(false)
  const [status, setStatus] = useState<string | null>(null)

  if (!user) {
    return null
  }

  async function handleUpload() {
    if (!file) {
      setStatus('Selecione um arquivo .md antes de enviar.')
      return
    }

    if (!file.name.toLowerCase().endsWith('.md')) {
      setStatus('Apenas arquivos .md são permitidos.')
      return
    }

    setIsUploading(true)
    setStatus('Enviando arquivo...')

    try {
      const response = await uploadMarkdown(file)
      setStatus(`Upload concluído: ${response.bucket}/${response.key}`)
      setFile(null)
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Erro inesperado no upload'
      setStatus(message)
    } finally {
      setIsUploading(false)
    }
  }

  return (
    <section className="card upload">
      <h3>Upload de Markdown</h3>
      <p>Selecione um arquivo no formato .md para armazenar no seu bucket.</p>

      <input
        type="file"
        accept=".md,text/markdown"
        onChange={(event) => {
          const selectedFile = event.target.files?.[0] ?? null
          setFile(selectedFile)
          setStatus(selectedFile ? `Arquivo selecionado: ${selectedFile.name}` : null)
        }}
      />

      <button onClick={handleUpload} disabled={isUploading}>
        {isUploading ? 'Enviando...' : 'Enviar arquivo'}
      </button>

      {status && <p className="upload-status">{status}</p>}
    </section>
  )
}
