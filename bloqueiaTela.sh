#!/usr/bin/env bash
#
# -----------------------------------------------------
#
# Script		: bloqueiaTela.sh
# Descrição		: bloqueia a tela do i3wm com a ferramenta i3lock
# Versão		: 1.1
# Autor			: Eppur Si Muove
# Contato		: eppur.si.muove@keemail.me
# Criação		: 15/01/2020
# Modificação	: 19/01/2020
# Licença		: GNU/GPL v3.0
#
# ------------------------------------------------------
#
# Uso:		bloqueiaTela.sh [dir-icons]
#
#			dir-icons
#				: é o diretório que contém as
#				: os ícones .png que você deseja
#				: exibir na tela de bloqueio.
#
#			ATALHO NO I3WM
#				: inserir tecla de atalho no arquivo de
#				: configuração do i3 (~/.config/i3/config)
#				: que execute esse script.
#
#				: Exemplo:
#				: bindsym $mod+l exec /caminho/do/bloqueiaTela.sh /diretorio/de/iconesPng
#				: exec --no-startup-id xautolock -time 2 -locker "/caminho/do/bloqueiaTela.sh /diretorio/de/iconesPng" &
#
#			ERROS DE EXECUÇÃO
#				: Os erros de execução do script serão
#				: gravados no arquivo $HOME/ErroBloqueioTela.
#
# ------------------------------------------------------

# ------------| Dependências externas |-------------- #
#
# Para funcionar esse script precisa que os seguintes pacotes estejam instalados
# e disponíveis para uso na sua máquina:
# >> maim ( tira capturas de tela do desktop )
# >> imagemagick ( pacote com várias ferramentas para manipulação de imagens ).

# -------------| Variáveis iniciais |--------------- #
usuario=$(grep $USER /etc/passwd | cut -d ':' -f5 | cut -d ',' -f1)
data=$(date +'%d-%m-%Y %H:%M:%S')
errArq="$HOME/ErroBloqueioTela"
bgImg=/tmp/$(date +'%Y%m%d-%H%M%S').png
bgText=/tmp/bgText.png
declare -a arrIcones
i=0

# Testa se o script está sendo chamado com o parâmetro obrigatório
# Lança descrição do erro no arquivo errArq
if [[ $# -ne 1 ]]; then
	tee $errArq <<< "$data Número de parâmetros incorreto ($1). Revise seu comando."
	exit 1
fi

# Testa se o diretório informado como parâmetro existe
if [[ ! -d $1 ]]; then
	tee $errArq <<< "$data $1 : Diretório não existe."
	exit 1
fi

# Variável imgs recebe número de icones PNG dentro do diretório especificado
numImgs=$(ls $1/*.png 2> /dev/null | wc -l)

# Testa se há icones PNG no diretório.
if [[ $numImgs -eq 0 ]]; then
	tee $errArq <<< "$data $1: diretório não contém icones PNG."
	exit 1
fi

# Inicializa a variável de aleatoriedade
RANDOM=$$

# Armazena um número aleatório conforme a quantidade de
# imagens disponíveis na pasta indicada
rNum=$(( $RANDOM % $(( $numImgs + 1 )) ))

# Armazena o nome de cada imagem em uma posição na matriz arrIcones
for img in $(ls $1/*.png); do
	arrIcones[$i]=$img
	let i++
done

# Obtem captura da tela e armazena em bgImg
maim $bgImg

# Adiciona efeito blur à captura de tela
convert $bgImg -blur 0x6 $bgImg

# Cria imagem com texto pedindo para digitar senha # Editar aqui conforme sua tela e preferências
[[ -f $bgText ]] && rm $bgText
convert $bgText -size 3000x150 xc:black \
				-font Liberation-Sans \
				-pointsize 70 \
				-fill white \
				-gravity center \
				-annotate +0+0 "Olá $usuario, digite sua senha para desbloquear" $bgText;

convert $bgText -alpha set \
				-channel A \
				-evaluate set 65% $bgText;

# Junta a captura com a imagem do texto criada anteriormente # Editar aqui conforme sua tela e preferências
convert $bgImg $bgText -gravity center -geometry +0+400 -composite $bgImg

# Junta o resultado da operação anterior com um ícone aleatório
convert $bgImg ${arrIcones[$rNum]} -gravity center -composite $bgImg

# aciona o bloqueador
i3lock -t --pointer=default -i $bgImg
