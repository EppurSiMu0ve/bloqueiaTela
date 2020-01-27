#!/usr/bin/env bash
#
# -----------------------------------------------------
#
# Script		: bloqueiaTela.sh
# Descrição		: bloqueia a tela do i3wm com a ferramenta i3lock
# Versão		: 1.2
# Autor			: Eppur Si Muove
# Contato		: eppur.si.muove@keemail.me
# Criação		: 15/01/2020
# Modificação		: 27/01/2020
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
#			DICAS
#				: talvez você queira alterar o texto exibido
#				: na tela de bloqueio ou algumas de suas propriedades,
#				: já que estão codificadas para resolução 1920x1080.
#				: Por isso deixei as indicações <<---------------| Alterar propriedades se necessário |---
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

# -------------| Variáveis iniciais |--------------- #
usuario=$(grep $USER /etc/passwd | cut -d ':' -f5 | cut -d ',' -f1)
data=$(date +'%Y%m%d-%H%M%S')
errArq="$HOME/ErroBloqueioTela"
bgImg="/tmp/$data.png"
bgText="/tmp/bgText.png"
declare -a arrIcones

# ------------| Dependências externas |-------------- #
#
# Para funcionar esse script precisa que os seguintes pacotes estejam instalados
# e disponíveis para uso na sua máquina:
# >> maim ( tira capturas de tela do desktop )
# >> imagemagick ( pacote com várias ferramentas para manipulação de imagens ).

if ( ! which convert &> /dev/null ); then
	tee $errArq <<< "$data Verifique dependências: sudo apt install imagemagick maim"
	exit 1
fi

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

# Armazena o nome de cada ícone .png do diretório $1 dentro da array arrIcones
arrIcones=( $1/*.png )

# Obtem captura da tela e armazena em bgImg
maim $bgImg

# Adiciona efeito blur à captura de tela
convert $bgImg -blur 0x6 $bgImg

# Cria imagem com texto pedindo para digitar senha. <<---------------------------| Alterar propriedades se necessário |---
# Vc pode modificar
#	-size (tamando da imagem largura x altura)
#	-pointsize (tamanho da fonte)
convert $bgText -size 3000x150 xc:black \
				-font Liberation-Sans \
				-pointsize 70 \
				-fill white \
				-gravity center \
				-annotate +0+0 "Olá $usuario, digite sua senha para desbloquear" $bgText;

convert $bgText -alpha set \
				-channel A \
				-evaluate set 65% $bgText;

# Junta a captura com a imagem do texto criada anteriormente <<------------------| Alterar propriedades se necessário |---
# Vc pode modificar
#	-geometry +0+x (x=altura que a imagem de texto vai ocupar a partir do centro).
convert $bgImg $bgText -gravity center -geometry +0+400 -composite $bgImg

# Junta o resultado da operação anterior com um ícone aleatório
convert $bgImg "${arrIcones[$rNum]}" -gravity center -composite $bgImg

# aciona o bloqueador
i3lock -t --pointer=default -i $bgImg

# limpa diretório tmp
rm $bgImg $bgText
