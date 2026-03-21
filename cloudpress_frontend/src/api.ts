const UPLOAD_API_URL = import.meta.env.VITE_UPLOAD_API_URL as string | undefined

export type UploadRequest = {
  title: string
  description: string
  isSponsored: boolean
}

type UploadResponse = {
  message: string
  bucket: string
  key: string
  uploadUrl: string
  expiresIn: number
  contentId: string
  contentCategory: 'markdown' | 'video'
}

function ensureUploadApiUrl() {
  if (!UPLOAD_API_URL) {
    throw new Error('VITE_UPLOAD_API_URL não configurada no frontend')
  }

  return UPLOAD_API_URL
}

export async function uploadContent(
  file: File,
  metadata: UploadRequest,
): Promise<UploadResponse> {
  const uploadApiUrl = ensureUploadApiUrl()

  const idToken = sessionStorage.getItem('id_token')
  if (!idToken) {
    throw new Error('Sessão inválida. Faça login novamente.')
  }

  const normalizedBaseUrl = uploadApiUrl.replace(/\/+$/, '')
  const response = await fetch(`${normalizedBaseUrl}/upload`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${idToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      filename: file.name,
      contentType: file.type || 'application/octet-stream',
      title: metadata.title,
      description: metadata.description,
      isSponsored: metadata.isSponsored,
    }),
  })

  const data = await response.json().catch(() => null)
  if (!response.ok) {
    const message = data?.message || 'Falha no upload'
    throw new Error(message)
  }

  const uploadData = data as UploadResponse

  const uploadResponse = await fetch(uploadData.uploadUrl, {
    method: 'PUT',
    headers: {
      'Content-Type': file.type || 'text/markdown',
    },
    body: file,
  })

  if (!uploadResponse.ok) {
    throw new Error('Falha ao enviar arquivo diretamente ao S3')
  }

  return uploadData
}
