import { useState } from 'react'
import { uploadContent } from '../api'

type Props = {
  user: string | null
}

export default function UploadBox({ user }: Props) {
  const [file, setFile] = useState<File | null>(null)
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [isSponsored, setIsSponsored] = useState(false)
  const [isUploading, setIsUploading] = useState(false)
  const [status, setStatus] = useState<string | null>(null)

  if (!user) {
    return null
  }

  async function handleUpload() {
    if (!file) {
      setStatus('Selecione um arquivo antes de enviar.')
      return
    }

    const normalizedTitle = title.trim()
    const normalizedDescription = description.trim()
    if (!normalizedTitle) {
      setStatus('Informe o titulo do conteudo.')
      return
    }

    if (!normalizedDescription) {
      setStatus('Informe a descricao do conteudo.')
      return
    }

    const extension = file.name.toLowerCase().split('.').pop() ?? ''
    const isMarkdown = extension === 'md' || extension === 'markdown'
    const isVideo = ['mp4', 'mov', 'avi', 'mkv', 'webm'].includes(extension)
    if (!isMarkdown && !isVideo) {
      setStatus('Envie um arquivo markdown ou video suportado.')
      return
    }

    setIsUploading(true)
    setStatus('Enviando arquivo...')

    try {
      const response = await uploadContent(file, {
        title: normalizedTitle,
        description: normalizedDescription,
        isSponsored,
      })
      setStatus(
        `Upload concluido: ${response.bucket}/${response.key} (${response.contentCategory})`,
      )
      setFile(null)
      setTitle('')
      setDescription('')
      setIsSponsored(false)
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
      <h3>Upload de Conteudo</h3>
      <p>Envie um markdown ou video com titulo, descricao e indicador de patrocinio.</p>

      <input
        type="text"
        placeholder="Titulo do conteudo"
        value={title}
        onChange={(event) => setTitle(event.target.value)}
      />

      <textarea
        placeholder="Descricao do conteudo"
        value={description}
        onChange={(event) => setDescription(event.target.value)}
        rows={4}
      />

      <label className="upload-checkbox">
        <input
          type="checkbox"
          checked={isSponsored}
          onChange={(event) => setIsSponsored(event.target.checked)}
        />
        <span>Conteudo patrocinado</span>
      </label>

      <input
        type="file"
        accept=".md,.markdown,video/*"
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
